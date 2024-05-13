import os
import shutil

def find_files(filename, search_path):
    result = []
    # Walk through all directories and files in search_path
    for root, dirs, files in os.walk(search_path):
        if filename in files:
            result.append(os.path.join(root, filename))
    return result

def main(filenames_path, search_dir, save_dir):
    # Read file names from filenames.txt
    with open(filenames_path, 'r') as file:
        file_names = [line.strip() for line in file.readlines()]

    found_files = []
    not_found_files = []

    # Ensure save_dir exists
    os.makedirs(save_dir, exist_ok=True)

    for file_name in file_names:
        # Find the file in the search directory
        found_paths = find_files(file_name, search_dir)
        if found_paths:
            # If found, copy the first occurrence to save_dir. If the file has "default_", "doors_", "farming_", "fire_", "wool_" then prepend the save name with "smcl_nodes_"
            save_name = file_name
            shutil.copy2(found_paths[0], os.path.join(save_dir, save_name))
            found_files.append(file_name)

        else:
            not_found_files.append(file_name)

    # Write found and not found file names to their respective files
    with open(os.path.join(save_dir, 'Found.txt'), 'w') as f:
        f.write('\n'.join(found_files))
    
    with open(os.path.join(save_dir, 'could_not_find.txt'), 'w') as f:
        f.write('\n'.join(not_found_files))

# Example usage
if __name__ == "__main__":
    filenames_path = 'filenames.txt'  # This should be the path to your filenames.txt file
    search_dir = '/home/mistere/Desktop/SatlantisStudios_TODELETE/REFI_Textures-master'  # Set this to your search directory
    save_dir = '/home/mistere/Desktop/SatlantisStudios_TODELETE/minetest/worlds/satlantis_world_1/worldmods/satlantis_mcl_nodes/textures'  # Set this to your save directory
    main(filenames_path, search_dir, save_dir)
