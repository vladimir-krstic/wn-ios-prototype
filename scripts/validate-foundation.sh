#!/bin/sh
set -eu

REPO_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
export WN_PROTOTYPE_REPO_DIR="$REPO_DIR"

python3 - <<'PY'
import json
import os
import pathlib
import re
import sys
from datetime import datetime, timezone

root = pathlib.Path(os.environ["WN_PROTOTYPE_REPO_DIR"])
errors: list[str] = []

def load_json(path: pathlib.Path):
    try:
        return json.loads(path.read_text())
    except Exception as exc:
        errors.append(f"invalid JSON {path.relative_to(root)}: {exc}")
        return {}

screens_path = root / "docs/catalogs/screens.json"
scenarios_path = root / "docs/catalogs/scenarios.json"
screens_data = load_json(screens_path)
scenarios_data = load_json(scenarios_path)

allowed = screens_data.get("allowedStatuses", [])
screens = screens_data.get("screens", [])
screen_ids = [item.get("id") for item in screens]
if len(screen_ids) != len(set(screen_ids)):
    errors.append("duplicate ScreenID in screens catalog")

rank = {status: index for index, status in enumerate(allowed)}
for item in screens:
    screen_id = item.get("id")
    status = item.get("status")
    contract_value = item.get("contract", "")
    if status not in rank:
        errors.append(f"{screen_id}: invalid status {status!r}")
    contract = root / contract_value
    if not contract.is_file():
        errors.append(f"{screen_id}: missing contract {contract_value}")
        continue
    text = contract.read_text()
    if f"`{screen_id}`" not in text:
        errors.append(f"{screen_id}: contract does not name its ScreenID")
    if f"Status: `{status}`" not in text:
        errors.append(f"{screen_id}: catalog and contract status differ")
    if rank.get(status, -1) >= rank.get("implemented", 3) and "pending" in text.lower():
        errors.append(f"{screen_id}: implemented-or-later contract still contains pending gates")

    implementation_value = item.get("implementation")
    approval_rank = rank.get("independentlyApproved", 2)
    if rank.get(status, -1) < approval_rank and implementation_value is not None:
        errors.append(f"{screen_id}: implementation must be null before independent approval")
    if implementation_value is not None:
        if not isinstance(implementation_value, str) or not implementation_value.startswith("WhiteNoisePrototype/Screens/") or not implementation_value.endswith(".swift"):
            errors.append(f"{screen_id}: invalid implementation path {implementation_value!r}")
        elif rank.get(status, -1) >= rank.get("implemented", 3) and not (root / implementation_value).is_file():
            errors.append(f"{screen_id}: implemented-or-later screen is missing {implementation_value}")
    elif rank.get(status, -1) >= rank.get("implemented", 3):
        errors.append(f"{screen_id}: implemented-or-later screen has no implementation path")

registered_implementations = {
    item["implementation"]
    for item in screens
    if isinstance(item.get("implementation"), str)
}
screens_directory = root / "WhiteNoisePrototype/Screens"
present_implementations = {
    str(path.relative_to(root))
    for path in screens_directory.rglob("*.swift")
} if screens_directory.is_dir() else set()
unregistered_implementations = sorted(present_implementations - registered_implementations)
if unregistered_implementations:
    errors.append(f"unregistered screen implementation files: {unregistered_implementations}")

scenario_items = scenarios_data.get("scenarios", [])
scenario_ids = [item.get("id") for item in scenario_items]
if len(scenario_ids) != len(set(scenario_ids)):
    errors.append("duplicate ScenarioID in scenarios catalog")
unknown_screens = sorted({item.get("screen") for item in scenario_items} - set(screen_ids))
if unknown_screens:
    errors.append(f"scenarios reference unknown screens: {unknown_screens}")
allowed_scenario_classes = {"default", "populated", "empty", "loading", "offline", "error", "permission", "recovery", "destructive", "longContent", "accessibility"}
unknown_classes = sorted({item.get("class") for item in scenario_items} - allowed_scenario_classes)
if unknown_classes:
    errors.append(f"scenarios use unknown classes: {unknown_classes}")
unknown_system_modes = sorted({item.get("systemMode") for item in scenario_items} - {"live", "simulated"})
if unknown_system_modes:
    errors.append(f"scenarios use unknown system modes: {unknown_system_modes}")

def swift_raw_values(path: pathlib.Path) -> set[str]:
    return set(re.findall(r'=\s*"([a-z0-9.-]+)"', path.read_text()))

swift_screens = swift_raw_values(root / "WhiteNoisePrototype/Foundation/ScreenID.swift")
swift_scenarios = swift_raw_values(root / "WhiteNoisePrototype/Foundation/ScenarioID.swift")
if swift_screens != set(screen_ids):
    errors.append(f"ScreenID Swift/catalog mismatch; swift-only={sorted(swift_screens-set(screen_ids))}, catalog-only={sorted(set(screen_ids)-swift_screens)}")
if swift_scenarios != set(scenario_ids):
    errors.append(f"ScenarioID Swift/catalog mismatch; swift-only={sorted(swift_scenarios-set(scenario_ids))}, catalog-only={sorted(set(scenario_ids)-swift_scenarios)}")

def swift_case_map(path: pathlib.Path) -> dict[str, str]:
    return dict(re.findall(r'case\s+(\w+)\s*=\s*"([a-z0-9.-]+)"', path.read_text()))

screen_case_map = swift_case_map(root / "WhiteNoisePrototype/Foundation/ScreenID.swift")
scenario_case_map = swift_case_map(root / "WhiteNoisePrototype/Foundation/ScenarioID.swift")
scenario_swift_text = (root / "WhiteNoisePrototype/Foundation/ScenarioID.swift").read_text()
switch_body = scenario_swift_text.split("switch self {", 1)[-1]
swift_scenario_screens: dict[str, str] = {}
for match in re.finditer(r'case\s+((?:\.\w+\s*,\s*)*\.\w+)\s*:\s*\.(\w+)', switch_body):
    screen_raw = screen_case_map.get(match.group(2))
    for case_name in re.findall(r'\.(\w+)', match.group(1)):
        scenario_raw = scenario_case_map.get(case_name)
        if scenario_raw and screen_raw:
            swift_scenario_screens[scenario_raw] = screen_raw
catalog_scenario_screens = {item.get("id"): item.get("screen") for item in scenario_items}
if swift_scenario_screens != catalog_scenario_screens:
    mismatches = sorted(
        scenario_id
        for scenario_id in set(swift_scenario_screens) | set(catalog_scenario_screens)
        if swift_scenario_screens.get(scenario_id) != catalog_scenario_screens.get(scenario_id)
    )
    errors.append(f"ScenarioID startScreen/catalog mismatch: {mismatches}")

clock_match = re.search(
    r'timeIntervalSince1970:\s*([\d_]+)',
    (root / "WhiteNoisePrototype/Foundation/FixtureUniverse.swift").read_text(),
)
try:
    catalog_clock = int(datetime.fromisoformat(scenarios_data["fixedClock"].replace("Z", "+00:00")).astimezone(timezone.utc).timestamp())
except Exception as exc:
    errors.append(f"invalid scenario catalog fixedClock: {exc}")
    catalog_clock = None
swift_clock = int(clock_match.group(1).replace("_", "")) if clock_match else None
if swift_clock != catalog_clock:
    errors.append(f"fixture clock mismatch; Swift={swift_clock}, catalog={catalog_clock}")

for relative, expected_target in [
    ("CLAUDE.md", "AGENTS.md"),
    (".claude/skills/white-noise-ios-prototype", "../../.agents/skills/white-noise-ios-prototype"),
]:
    path = root / relative
    if not path.is_symlink():
        errors.append(f"{relative}: expected symlink")
    elif os.readlink(path) != expected_target:
        errors.append(f"{relative}: expected target {expected_target}, found {os.readlink(path)}")

pbx = (root / "WhiteNoisePrototype.xcodeproj/project.pbxproj").read_text()
required_pbx = [
    "IPHONEOS_DEPLOYMENT_TARGET = 27.0;",
    "TARGETED_DEVICE_FAMILY = 1;",
    "SUPPORTS_MACCATALYST = NO;",
    "SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD = NO;",
    "INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = UIInterfaceOrientationPortrait;",
    "PRODUCT_BUNDLE_IDENTIFIER = dev.ipf.whitenoise.ios.prototype;",
]
for value in required_pbx:
    if value not in pbx:
        errors.append(f"project missing setting: {value}")
configuration_pattern = re.compile(
    r'[A-Z0-9]{24} /\* (Debug|Release) \*/ = \{\s*isa = XCBuildConfiguration;\s*buildSettings = \{(.*?)\};\s*name = \1;\s*\};',
    re.DOTALL,
)
app_configurations = {
    name: settings
    for name, settings in configuration_pattern.findall(pbx)
    if "PRODUCT_BUNDLE_IDENTIFIER = dev.ipf.whitenoise.ios.prototype;" in settings
}
if set(app_configurations) != {"Debug", "Release"}:
    errors.append("project must contain app-specific Debug and Release build configurations")
for name, settings in app_configurations.items():
    for value in required_pbx:
        if value not in settings:
            errors.append(f"app {name} configuration missing setting: {value}")
    if re.search(r'INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone\s*=.*Landscape', settings):
        errors.append(f"app {name} configuration enables an iPhone landscape orientation")
for forbidden in ["XCRemoteSwiftPackageReference", "XCLocalSwiftPackageReference"]:
    if forbidden in pbx:
        errors.append(f"project contains package dependency marker: {forbidden}")

swift_text = "\n".join(path.read_text() for path in (root / "WhiteNoisePrototype").rglob("*.swift"))
for forbidden in [
    "import CryptoKit", "import Crypto", "import LocalAuthentication", "import Network",
    "import Security", "import SwiftData", "import CoreData", "URLSession", "URLRequest",
    "NSURLConnection", "UserDefaults", "@AppStorage", "@SceneStorage", "SceneStorage",
    "SecItem", "Keychain", "sqlite3", "Marmot", "Nostr",
]:
    if forbidden in swift_text:
        errors.append(f"Swift source contains prohibited runtime marker: {forbidden}")

if errors:
    for error in errors:
        print(f"ERROR: {error}", file=sys.stderr)
    raise SystemExit(1)

print(f"Foundation valid: {len(screen_ids)} screens, {len(scenario_ids)} scenarios, no prohibited runtime dependencies.")
PY
