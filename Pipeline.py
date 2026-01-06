import os
import glob
import subprocess
import pygltflib
import shutil
import time

# === Paths ===
import_request_list = r"C:\Users\ianth\OneDrive\Desktop\untitled\Emilys-Suprise\Assets_I_Will_Steal.txt"
export_path = r"C:\Users\ianth\OneDrive\Desktop\untitled\ACNH_2.0.0_Exported_Model_DAE+PNG\model"
import_path = r"C:\Users\ianth\OneDrive\Desktop\untitled\Emilys-Suprise\emily's-suprise-(ians-eyes-only)\Models\Final Models\Backyard"

# Path to COLLADA2GLTF executable
collada_converter = "COLLADA2GLTF"  # <-- change this


# === Helper Functions ===
def unique_name(dest_folder: str, file_name: str) -> str:
    """
    Returns a unique file path (adds 1, 2, 3... if file already exists).
    """
    name, ext = os.path.splitext(file_name)
    counter = 1
    new_name = file_name
    while os.path.exists(os.path.join(dest_folder, new_name)):
        new_name = f"{name}{counter}{ext}"
        counter += 1
    return os.path.join(dest_folder, new_name)


def dae_to_glb(item, dae_path):
    """
    Converts a .dae file to .glb and places it in the import_path/item folder.
    """
    item_folder = os.path.join(import_path, item)
    os.makedirs(item_folder, exist_ok=True)

    gltf_output = os.path.join(item_folder, f"{item}.gltf")
    glb_output = os.path.join(item_folder, f"{item}.glb")

    # Step 1: Run COLLADA2GLTF
    command = [
        collada_converter,
        dae_path,
        "-o", gltf_output,
        "--embed"
    ]
    print("Running:", " ".join(command))
    subprocess.run(command, check=True)

    # Step 2: Convert glTF → GLB
    gltf = pygltflib.GLTF2().load(gltf_output)
    gltf.save_binary(glb_output)
    os.remove(gltf_output)

    print(f"✅ Saved GLB: {glb_output}")


def export_textures(item, textures, icon_path=None):
    """
    Finds and copies textures related to an item into its /Textures subfolder.
    Also copies the icon if provided.
    """
    textures_folder = os.path.join(import_path, item, "Textures")
    os.makedirs(textures_folder, exist_ok=True)

    # Copy main textures
    if textures:
        for file in textures:
            if ("nrm" in file.lower() or "alb" in file.lower()) and "gryalb" not in file.lower():
                src = file
                dst = textures_folder

                # Get the base filename and extension
                filename = os.path.basename(src)
                name, ext = os.path.splitext(filename)
                dest_path = os.path.join(dst, filename)

                # If the file already exists, append a number (texture.png → texture1.png, texture2.png, etc.)
                counter = 1
                while os.path.exists(dest_path):
                    new_filename = f"{name}{counter}{ext}"
                    dest_path = os.path.join(dst, new_filename)
                    counter += 1

                # Copy the file with its new name
                shutil.copy2(src, dest_path)
                print(f"🖼️ Copied texture: {src} → {dest_path}")
    else:
        print(f"⚠️ No main textures found for {item}")

    if icon_path and os.path.exists(icon_path):
        _, ext = os.path.splitext(icon_path)
        icon_name = f"{item}_icon{ext}"
        dst = unique_name(textures_folder, icon_name)
        shutil.copy2(icon_path, dst)
        print(f"⭐ Copied icon: {icon_name} → {dst}")
    else:
        print(f"⚠️ No icon found for {item}")


def items_from_list_retrieve():
    """
    Reads item list, finds .dae + textures + icon, converts and exports.
    """
    with open(import_request_list, "r") as file:
        for line in file:
            item = line.strip()
            dae_path = ""
            icon_path = ""
            textures = []

            # Find matching folders
            matches = glob.glob(os.path.join(export_path, f"*{item}*"))
            for match in matches:
                if f'{item}.Nin' in match:
                    main_file_contents = os.listdir(match)
                    for content in main_file_contents:
                        if 'dae' in content:
                            dae_path = os.path.join(match, content)
                        else:
                            textures.append(os.path.join(match, content))
                    
                elif 'Layout_FtrIcon' in match:
                    if 'Remake.Nin' in match:
                        icon_files = glob.glob(os.path.join(match, "*"))
                        if icon_files:
                            icon_path = icon_files[0]
                    elif not icon_path and '_0_0' in match:
                        icon_files = glob.glob(os.path.join(match, "*"))
                        if icon_files:
                            icon_path = icon_files[0]
                elif 'DIY' not in match:
                    main_file_contents = os.listdir(match)
                    for content in main_file_contents:
                        textures.append(os.path.join(match, content))

            # Process item
            if dae_path:
                print(f"\n--- Processing {item} ---")
                dae_to_glb(item, dae_path)
                print(textures)
                export_textures(item, textures, icon_path)
            else:
                print(f"❌ No DAE found for {item}")
            
            # Delay before the next item
            time.sleep(1)


def operation_steal_wall_papers():
    wall_papers_to_steal = [
        "RoomTexFloorLawn00"
    ]

    base_src = "C:/Users/ianth/OneDrive/Desktop/untitled/ACNH_2.0.0_Exported_Model_DAE+PNG/Model"
    base_dest = "C:/Users/ianth/OneDrive/Desktop/untitled/Emilys-Suprise/emily's-suprise-(ians-eyes-only)/Floor and Wall Textures"

    wall_num = 22

    for wall_paper in wall_papers_to_steal:
        src = f"{base_src}/{wall_paper}.Nin_NX_NVN"
        dest = f"{base_dest}/Floor{wall_num}"

        wall_num += 1

        # Ensure destination folder exists
        os.makedirs(dest, exist_ok=True)

        # Copy all files from source folder
        if os.path.exists(src):
            for file in os.listdir(src):
                full_src = os.path.join(src, file)
                if os.path.isfile(full_src):
                    shutil.copy(full_src, dest)
            print(f"✅ Copied {wall_paper} → Wall{wall_num - 1}")
        else:
            print(f"⚠️ Source folder not found: {src}")

if __name__ == "__main__":
    items_from_list_retrieve()
