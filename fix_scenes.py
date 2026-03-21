import os
import re
import sys

def fix_tscn_file(filepath):
    """Fix missing id in ext_resource lines"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()

        modified = False
        new_lines = []
        id_counter = 1

        for line in lines:
            # Check if line is ext_resource without id
            if line.startswith('[ext_resource') and 'id=' not in line:
                # Extract the closing bracket
                line = line.rstrip()
                if line.endswith(']'):
                    # Insert id before the closing bracket
                    line = line[:-1] + f' id="{id_counter}"]' + '\n'
                    id_counter += 1
                    modified = True

            # Fix ExtResource references without quotes
            if 'ExtResource("res://' in line:
                # Change ExtResource("res://path") to ExtResource("id")
                line = re.sub(r'ExtResource\("res://[^"]+"\)', f'ExtResource("{id_counter - 1}")', line)
                modified = True

            new_lines.append(line)

        if modified:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.writelines(new_lines)
            print(f"Fixed: {filepath}")
            return True
        else:
            print(f"Skipped (no changes needed): {filepath}")
            return False

    except Exception as e:
        print(f"Error processing {filepath}: {e}")
        return False

def main():
    base_dir = "D:/Work/VibeGameing/mini-game/scenes"
    fixed_count = 0

    # Walk through all .tscn files
    for root, dirs, files in os.walk(base_dir):
        for file in files:
            if file.endswith('.tscn'):
                filepath = os.path.join(root, file)
                if fix_tscn_file(filepath):
                    fixed_count += 1

    print(f"\nTotal files fixed: {fixed_count}")

if __name__ == "__main__":
    main()
