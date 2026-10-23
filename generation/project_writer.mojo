# WorldSmith/generation/project_writer.mojo

import os

from models.model import ProjectManifest


def validate_relative_path(path: String) raises:
    if path == "":
        raise Error("Generated file has an empty path")

    if path.startswith("/"):
        raise Error("Absolute output paths are not allowed: " + path)

    if "\\" in path:
        raise Error("Backslashes are not allowed in generated paths: " + path)

    if ".." in path:
        raise Error("Parent-directory traversal is not allowed: " + path)

    if path.startswith("."):
        raise Error("Hidden or special output paths are not allowed: " + path)


def write_project(
    manifest: ProjectManifest,
    output_root: String,
    max_files: Int,
    max_file_size_bytes: Int
) raises:
    if output_root == "":
        raise Error("Output directory cannot be empty")

    if manifest.file_count() == 0:
        raise Error("The project manifest contains no files")

    if manifest.file_count() > max_files:
        raise Error("Project exceeds the configured file-count limit")

    os.makedirs(output_root, exist_ok=True)

    for i in range(len(manifest.files)):
        var generated_file = manifest.files[i]
        validate_relative_path(generated_file.path)

        if len(generated_file.content) > max_file_size_bytes:
            raise Error(
                "Generated file exceeds size limit: "
                + generated_file.path
            )

        var full_path = output_root + "/" + generated_file.path
        var parent_and_name = os.path.split(full_path)
        var parent_directory = parent_and_name[0]

        if parent_directory != "":
            os.makedirs(parent_directory, exist_ok=True)

        with open(full_path, "w") as output_file:
            output_file.write(generated_file.content)

        print("Wrote: " + full_path)