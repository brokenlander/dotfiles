#!/usr/bin/env python3
"""
File Manager Utility
A simple tool for basic file operations
"""
import datetime
import os
import shutil
import sys


class FileManager:
    def __init__(self, base_directory="."):
        self.base_directory = os.path.abspath(base_directory)
        if not os.path.exists(self.base_directory):
            os.makedirs(self.base_directory)

    def create_file(self, filename, content=""):
        """Create a new file with optional content"""
        full_path = os.path.join(self.base_directory, filename)
        with open(full_path, "w") as file:
            file.write(content)
        return f"Created file: {filename}"

    def read_file(self, filename):
        """Read and return file contents"""
        full_path = os.path.join(self.base_directory, filename)
        if not os.path.exists(full_path):
            return f"Error: File {filename} not found"
        with open(full_path, "r") as file:
            return file.read()

    def list_files(self, show_details=False):
        """List all files in the managed directory"""
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
            result.append(f"{file} - Size: {size} bytes, Modified: {modified}")
        return result

    def delete_file(self, filename):
        """Delete the specified file"""
        full_path = os.path.join(self.base_directory, filename)
        if not os.path.exists(full_path):
            return f"Error: File {filename} not found"

        if os.path.isdir(full_path):
            shutil.rmtree(full_path)
        else:
            os.remove(full_path)
        return f"Deleted: {filename}"


# Example usage
if __name__ == "__main__":
    manager = FileManager("./my_files")
    print(manager.create_file("example.txt", "Hello, world!"))
    print(manager.read_file("example.txt"))
    print(manager.list_files(show_details=True))
