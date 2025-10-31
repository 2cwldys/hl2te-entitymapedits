import tkinter as tk
from tkinter import simpledialog, messagebox
import os
import re
import subprocess
import platform

root = tk.Tk()
root.withdraw()

# --- Step 1: Auto-locate sv_custommaps.lua ---
target_file = None
for root_dir, dirs, files in os.walk("."):
    for file in files:
        if file == "sv_custommaps.lua":
            target_file = os.path.join(root_dir, file)
            break
    if target_file:
        break

if not target_file:
    messagebox.showerror("Error", "Could not find sv_custommaps.lua in current directory or subfolders.")
    exit()

# --- Step 2: Ask for map name ---
map_name = simpledialog.askstring("Map Name", "Enter map name (e.g., gm_construct):")
if not map_name:
    messagebox.showinfo("Cancelled", "No map name entered. Exiting.")
    exit()

# --- Step 3: Ask for entity string ---
entity_data = simpledialog.askstring(
    "Entity Data",
    f"Paste your entity data for {map_name}:"
)
if not entity_data:
    messagebox.showinfo("Cancelled", "No entity data entered. Exiting.")
    exit()

# Strip only trailing whitespace (keep internal formatting intact)
entity_data = entity_data.rstrip()

# --- Step 4: Read existing Lua code ---
with open(target_file, "r", encoding="utf-8") as f:
    lua_code = f.read()

# --- Step 5: Inject the variable after IsWorkshopAddonInstalled check ---
insertion_pattern = r"(\s*)(if not IsWorkshopAddonInstalled\(REQUIRED_ADDON_ID\) then return end)\s*\n"
match = re.search(insertion_pattern, lua_code)
if match:
    indent = match.group(1)  # Capture existing indentation

    # Strip all leading/trailing newlines from entity_data
    entity_clean = entity_data.strip("\n")

    # Indent each line properly
    indented_entity = "\n".join(indent + line for line in entity_clean.split("\n"))

    # Add exactly ONE blank line before and after
    variable_code = f"{indent}local {map_name} = [[\n{indented_entity}\n{indent}]]\n"

    new_lua = re.sub(insertion_pattern, r"\1\2\n" + variable_code, lua_code, count=1)
else:
    messagebox.showerror("Error", "Could not find IsWorkshopAddonInstalled line in the file.")
    exit()

# --- Step 6: Add to maps table ---
maps_pattern = r"(\s*)(customEntityMaps\s*=\s*\{\s*\n)(\s*)(\w+\s*=)"
match = re.search(maps_pattern, new_lua)
if match:
    table_indent = match.group(3)  # Indentation of entries inside the table
    maps_entry = f"{table_indent}{map_name} = {map_name},\n"

    new_lua = re.sub(
        r"(customEntityMaps\s*=\s*\{)\s*\n",
        r"\1\n" + maps_entry,
        new_lua,
        count=1
    )
else:
    messagebox.showerror("Error", "Could not find maps table in the file.")
    exit()

# --- Step 7: Save changes ---
with open(target_file, "w", encoding="utf-8") as f:
    f.write(new_lua)

messagebox.showinfo("Success", f"Added {map_name} to {target_file} successfully!")

# --- Step 8: Open file in default editor ---
try:
    abs_path = os.path.abspath(target_file)
    if platform.system() == "Windows":
        subprocess.run(["notepad.exe", abs_path])
    elif platform.system() == "Darwin":  # macOS
        subprocess.run(["open", abs_path])
    else:  # Linux
        subprocess.run(["xdg-open", abs_path])
except Exception as e:
    print(f"Could not open file automatically: {e}")
