#!/usr/bin/env python3
"""
File Manager Utility
A simple tool for basic file operations
"""
import datetime
import os
import shutil
import sys
from typing import List, Optional, Union


class FileManager:
    """
    A utility class for managing files in a specified directory.

    Provides functionality for creating, reading, listing, copying, moving,
    and deleting files within a base directory.
    """

    def __init__(self, base_directory: str = "."):
        """
        Initialize the FileManager with a base directory.

        Args:
            base_directory: The directory to manage files in (default: current directory)
        """
        self.base_directory = os.path.abspath(base_directory)
        try:
            if not os.path.exists(self.base_directory):
                os.makedirs(self.base_directory)
        except OSError as e:
            print(f"Error creating directory {base_directory}: {e}")
            raise

    def _validate_path(self, filename: str) -> str:
        """
        Validate and return the full path for a filename.

        Args:
            filename: The name of the file

        Returns:
            The full path to the file

        Raises:
            ValueError: If the filename contains invalid characters or would escape the base directory
        """
        # Prevent directory traversal attacks
        norm_path = os.path.normpath(os.path.join(self.base_directory, filename))
        if not norm_path.startswith(self.base_directory):
            raise ValueError(
                f"Invalid filename: {filename} (attempts to escape base directory)"
            )
        return norm_path

    def create_file(self, filename: str, content: str = "") -> str:
        """
        Create a new file with optional content.

        Args:
            filename: The name of the file to create
            content: The content to write to the file (default: empty string)

        Returns:
            A message indicating the file was created

        Raises:
            OSError: If there's an error writing the file
        """
        try:
            full_path = self._validate_path(filename)
            # Create parent directories if they don't exist
            os.makedirs(os.path.dirname(full_path), exist_ok=True)
            with open(full_path, "w") as file:
                file.write(content)
            return f"Created file: {filename}"
        except (OSError, ValueError) as e:
            return f"Error creating file {filename}: {e}"

    def read_file(self, filename: str) -> str:
        """
        Read and return file contents.

        Args:
            filename: The name of the file to read

        Returns:
            The contents of the file or an error message

        Raises:
            OSError: If there's an error reading the file
        """
        try:
            full_path = self._validate_path(filename)
            if not os.path.exists(full_path):
                return f"Error: File {filename} not found"
            if os.path.isdir(full_path):
                return f"Error: {filename} is a directory, not a file"
            with open(full_path, "r") as file:
                return file.read()
        except (OSError, ValueError) as e:
            return f"Error reading file {filename}: {e}"

    def list_files(self, show_details: bool = False) -> Union[List[str], List[dict]]:
        """
        List all files in the managed directory.

        Args:
            show_details: Whether to include file details (size, modified date)

        Returns:
            A list of filenames or detailed file information

        Raises:
            OSError: If there's an error accessing the directory
        """
        try:
            files = os.listdir(self.base_directory)
            if not show_details:
                return files

            result = []
            for file in files:
                full_path = os.path.join(self.base_directory, file)
                stats = os.stat(full_path)
                size = stats.st_size
                modified = datetime.datetime.fromtimestamp(stats.st_mtime).strftime(
                    "%Y-%m-%d %H:%M:%S"
                )
                file_type = "Directory" if os.path.isdir(full_path) else "File"
                result.append(
                    f"{file} - Type: {file_type}, Size: {size} bytes, Modified: {modified}"
                )
            return result
        except OSError as e:
            return [f"Error listing files: {e}"]

    def delete_file(self, filename: str) -> str:
        """
        Delete the specified file or directory.

        Args:
            filename: The name of the file or directory to delete

        Returns:
            A message indicating the file was deleted or an error message

        Raises:
            OSError: If there's an error deleting the file
        """
        try:
            full_path = self._validate_path(filename)
            if not os.path.exists(full_path):
                return f"Error: File {filename} not found"

            if os.path.isdir(full_path):
                shutil.rmtree(full_path)
            else:
                os.remove(full_path)
            return f"Deleted: {filename}"
        except (OSError, ValueError) as e:
            return f"Error deleting {filename}: {e}"

    def copy_file(self, source: str, destination: str) -> str:
        """
        Copy a file or directory to a new location.

        Args:
            source: The source file or directory
            destination: The destination path

        Returns:
            A message indicating the file was copied or an error message

        Raises:
            OSError: If there's an error copying the file
        """
        try:
            source_path = self._validate_path(source)
            dest_path = self._validate_path(destination)

            if not os.path.exists(source_path):
                return f"Error: Source {source} not found"

            # Create parent directories if they don't exist
            os.makedirs(os.path.dirname(dest_path), exist_ok=True)

            if os.path.isdir(source_path):
                shutil.copytree(source_path, dest_path)
            else:
                shutil.copy2(source_path, dest_path)
            return f"Copied {source} to {destination}"
        except (OSError, ValueError) as e:
            return f"Error copying {source} to {destination}: {e}"

    def move_file(self, source: str, destination: str) -> str:
        """
        Move a file or directory to a new location.

        Args:
            source: The source file or directory
            destination: The destination path

        Returns:
            A message indicating the file was moved or an error message

        Raises:
            OSError: If there's an error moving the file
        """
        try:
            source_path = self._validate_path(source)
            dest_path = self._validate_path(destination)

            if not os.path.exists(source_path):
                return f"Error: Source {source} not found"

            # Create parent directories if they don't exist
            os.makedirs(os.path.dirname(dest_path), exist_ok=True)

            shutil.move(source_path, dest_path)
            return f"Moved {source} to {destination}"
        except (OSError, ValueError) as e:
            return f"Error moving {source} to {destination}: {e}"


# Example usage
if __name__ == "__main__":
    manager = FileManager("./my_files")
    print(manager.create_file("example.txt", "Hello, world!"))
    print(manager.read_file("example.txt"))
    print(manager.list_files(show_details=True))

    # Examples of new functionality
    print(manager.copy_file("example.txt", "example_copy.txt"))
    print(manager.move_file("example_copy.txt", "moved_example.txt"))
