#!/usr/bin/env python3
"""
Package Update Automation Script

This script automates the process of checking for package updates and preparing pull requests:
1. Runs the version checker to identify packages with updates available
2. For each package with an update:
   - Checks if a PR already exists for this update
   - Creates a new branch
   - Updates the changelog with the new version
   - Runs 'make update-pin' to update the package
   - Commits the changes
   - Returns to master branch

Usage:
    python3 update_packages.py

Author: Manus AI
Date: May 30, 2025
"""

import os
import sys
import json
import re
import subprocess
from pathlib import Path
from datetime import datetime


def run_command(command, cwd=None, capture_output=True, check=True):
    """
    Run a shell command and return its output.
    
    Args:
        command: Command to run (string or list)
        cwd: Working directory
        capture_output: Whether to capture and return output
        check: Whether to check for errors
        
    Returns:
        Command output if capture_output is True, otherwise None
    """
    if isinstance(command, str):
        command_str = command
    else:
        command_str = " ".join(command)
    
    print(f"Running: {command_str}")
    
    result = subprocess.run(
        command,
        cwd=cwd,
        capture_output=capture_output,
        text=True,
        check=check,
        shell=isinstance(command, str)
    )
    
    if capture_output:
        return result.stdout.strip()
    return None


def get_packages_with_updates():
    """
    Run the version checker script and get packages with updates available.
    
    Returns:
        List of dictionaries with package update information
    """
    script_dir = os.path.dirname(os.path.abspath(__file__))
    version_checker_path = os.path.join(script_dir, "version_checker.py")
    
    # Run the version checker with JSON output
    result = run_command([sys.executable, version_checker_path, "--json-output"])
    
    # Parse the JSON output
    updates = json.loads(result)
    
    # Filter for packages with updates available
    return [pkg for pkg in updates if pkg.get("is_update_available", False)]


def check_existing_pr(package_name, target_version):
    """
    Check if a PR already exists for updating this package to the target version.
    
    Args:
        package_name: Name of the package
        target_version: Version to update to
        
    Returns:
        True if a PR exists, False otherwise
    """
    # Use GitHub CLI to list PRs
    try:
        # List open PRs with a title containing the package name
        result = run_command(
            f"gh pr list --search \"in:title {package_name} update\" --json title,body",
            check=False
        )
        
        # If gh command failed or returned no results
        if not result or result == "[]":
            return False
            
        prs = json.loads(result)
        
        # Check if any PR is for updating this package to the target version
        for pr in prs:
            title = pr.get("title", "")
            body = pr.get("body", "")
            
            # Check if PR title or body mentions the package and version
            if (package_name.lower() in title.lower() and target_version in title) or \
               (package_name.lower() in body.lower() and target_version in body):
                print(f"PR already exists for {package_name} to version {target_version}")
                return True
                
        return False
    except Exception as e:
        print(f"Error checking for existing PRs: {e}")
        # If we can't check, assume no PR exists
        return False


def create_branch(package_name):
    """
    Create and checkout a new branch for the package update.
    
    Args:
        package_name: Name of the package
        
    Returns:
        Branch name
    """
    # Create a branch name with timestamp to avoid conflicts
    timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
    branch_name = f"update-{package_name}-{timestamp}"
    
    # Create and checkout the branch
    run_command(["git", "checkout", "-b", branch_name])
    
    return branch_name


def update_changelog(package_name, new_version):
    """
    Update the changelog for the package with the new version.
    
    Args:
        package_name: Name of the package
        new_version: New version to add to changelog
        
    Returns:
        True if successful, False otherwise
    """
    repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    changelog_path = os.path.join(repo_root, "pkg_specs", f"{package_name}.changelog")
    
    if not os.path.exists(changelog_path):
        print(f"Changelog not found for {package_name}")
        return False
    
    try:
        # Read the current changelog
        with open(changelog_path, "r") as f:
            changelog_content = f.read()
        
        # Get the current date in Debian changelog format
        today = datetime.now().strftime("%a, %d %b %Y %H:%M:%S +0000")
        
        # Create a new changelog entry
        # Strip 'v' prefix if present in version
        clean_version = new_version[1:] if new_version.startswith("v") else new_version
        
        # Remove any trailing parts like -beta, -rc1, etc.
        clean_version = re.sub(r'[-+].*$', '', clean_version)
        
        new_entry = f"{package_name} ({clean_version}-1) bullseye; urgency=medium\n\n"
        new_entry += f"  * Update to upstream version {clean_version}\n\n"
        new_entry += f" -- Martin Habovštiak <martin.habovstiak@gmail.com>  {today}\n\n"
        
        # Prepend the new entry to the changelog
        updated_changelog = new_entry + changelog_content
        
        # Write the updated changelog
        with open(changelog_path, "w") as f:
            f.write(updated_changelog)
            
        return True
    except Exception as e:
        print(f"Error updating changelog for {package_name}: {e}")
        return False


def run_update_pin(package_name, source_name):
    """
    Run 'make update-pin' for the package.
    
    Args:
        package_name: Name of the package
        source_name: Source name for the package
        
    Returns:
        True if successful, False otherwise
    """
    repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    
    try:
        # Set BUILD_DIR to an absolute path (equivalent to $HOME/cadr-build)
        build_dir = os.path.expanduser("~/cadr-build")
        
        # Run make update-pin with BUILD_DIR set to absolute path
        run_command(
            ["make", f"SOURCES={source_name}", f"BUILD_DIR={build_dir}", "update-pin"],
            cwd=repo_root,
            capture_output=False
        )
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error running update-pin for {package_name}: {e}")
        return False


def commit_changes(package_name, new_version):
    """
    Commit the changes to the branch.
    
    Args:
        package_name: Name of the package
        new_version: New version being updated to
        
    Returns:
        True if successful, False otherwise
    """
    try:
        # Add all changes
        run_command(["git", "add", "."])
        
        # Create commit message
        clean_version = new_version[1:] if new_version.startswith("v") else new_version
        commit_message = f"Update {package_name} to {clean_version}\n\n"
        commit_message += f"Automated update to upstream version {clean_version}"
        
        # Commit the changes
        run_command(["git", "commit", "-m", commit_message])
        
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error committing changes for {package_name}: {e}")
        return False


def switch_to_master():
    """
    Switch back to the master branch.
    
    Returns:
        True if successful, False otherwise
    """
    try:
        run_command(["git", "checkout", "master"])
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error switching to master branch: {e}")
        return False


def process_package_update(package):
    """
    Process a single package update.
    
    Args:
        package: Package update information dictionary
        
    Returns:
        Dictionary with update results
    """
    package_name = package["project_name"]
    source_name = package["source_name"]
    new_version = package["latest_version_tag"]
    
    print(f"\nProcessing update for {package_name} to version {new_version}")
    
    # Check if a PR already exists
    if check_existing_pr(package_name, new_version):
        return {
            "package": package_name,
            "version": new_version,
            "status": "skipped",
            "reason": "PR already exists"
        }
    
    # Create a new branch
    branch_name = create_branch(package_name)
    
    # Update the changelog
    changelog_updated = update_changelog(package_name, new_version)
    if not changelog_updated:
        # Switch back to master before returning
        switch_to_master()
        return {
            "package": package_name,
            "version": new_version,
            "status": "failed",
            "reason": "Failed to update changelog"
        }
    
    # Run update-pin
    update_successful = run_update_pin(package_name, source_name)
    if not update_successful:
        # Switch back to master before returning
        switch_to_master()
        return {
            "package": package_name,
            "version": new_version,
            "status": "failed",
            "reason": "Failed to run update-pin"
        }
    
    # Commit the changes
    commit_successful = commit_changes(package_name, new_version)
    if not commit_successful:
        # Switch back to master before returning
        switch_to_master()
        return {
            "package": package_name,
            "version": new_version,
            "status": "failed",
            "reason": "Failed to commit changes"
        }
    
    # Switch back to master branch after processing this package
    switch_to_master()
    
    return {
        "package": package_name,
        "version": new_version,
        "status": "success",
        "branch": branch_name
    }


def main():
    """Main function to run the package update automation."""
    # Get packages with updates available
    print("Checking for package updates...")
    packages_with_updates = get_packages_with_updates()
    
    if not packages_with_updates:
        print("No package updates available")
        return
    
    print(f"Found {len(packages_with_updates)} packages with updates available")
    
    # Process each package update
    results = []
    for package in packages_with_updates:
        result = process_package_update(package)
        results.append(result)
    
    # Print summary
    print("\nUpdate Summary:")
    for result in results:
        status = result["status"]
        if status == "success":
            print(f"✅ {result['package']} updated to {result['version']} on branch {result['branch']}")
        elif status == "skipped":
            print(f"⏭️ {result['package']} skipped: {result['reason']}")
        else:
            print(f"❌ {result['package']} failed: {result['reason']}")
    
    # Output JSON for GitHub Actions
    output_file = os.environ.get("GITHUB_OUTPUT")
    if output_file:
        with open(output_file, "a") as f:
            f.write(f"update_results={json.dumps(results)}\n")
    
    # Return success only if all updates were successful or skipped
    for result in results:
        if result["status"] not in ["success", "skipped"]:
            sys.exit(1)


if __name__ == "__main__":
    main()
