#!/usr/bin/env python3
"""
Version Checker Script

This script compares the latest GitHub version tags of projects in the cryptoanarchy-deb-repo-builder
repository with the versions in their respective changelog files in the pkg_specs directory.

The script identifies which packages have updates available by comparing:
1. The latest version tag from GitHub (fetched live with full pagination)
2. The version in the top line of the changelog (accounting for the '-number' suffix)

Usage:
    python3 version_checker.py [--json-output]

Options:
    --json-output    Output results in JSON format instead of human-readable text

Author: Manus AI
Date: May 30, 2025
"""

import os
import re
import json
import argparse
import csv
import time
import requests
from pathlib import Path


def load_projects_table(file_path):
    """
    Load the projects table from a CSV file.
    
    Args:
        file_path: Path to the CSV file containing the projects table
        
    Returns:
        List of dictionaries with project information
    """
    projects = []
    with open(file_path, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            projects.append(row)
    return projects


def extract_version_from_changelog(changelog_path):
    """
    Extract the version from the first line of a changelog file.
    
    Args:
        changelog_path: Path to the changelog file
        
    Returns:
        Tuple of (version, suffix) or (None, None) if not found or file doesn't exist
    """
    if not os.path.exists(changelog_path):
        return None, None
    
    try:
        with open(changelog_path, 'r') as f:
            first_line = f.readline().strip()
            
        # Expected format: "project_name (version-suffix) distribution; urgency=level"
        match = re.search(r'\(([\d\.]+)(?:-(\d+))?\)', first_line)
        if match:
            version = match.group(1)  # The version number
            suffix = match.group(2)   # The suffix (e.g., "1" in "1.2.3-1")
            return version, suffix
    except Exception as e:
        print(f"Error reading changelog {changelog_path}: {e}")
    
    return None, None


def is_version_tag(tag):
    """
    Check if a tag is a proper version tag.
    
    Args:
        tag: Tag string to check
        
    Returns:
        Boolean indicating if the tag is a proper version tag
    """
    if not tag or not isinstance(tag, str):
        return False
    
    # Remove 'v' prefix if present for checking
    check_tag = tag[1:] if tag.startswith('v') else tag
    
    # Check if it matches a semantic version pattern (major.minor.patch)
    # Also allow simpler versions like 1.0 or just 1
    semver_pattern = r'^(\d+)(\.\d+)?(\.\d+)?([.-].*)?$'
    return bool(re.match(semver_pattern, check_tag))


def normalize_version(version):
    """
    Normalize a version string for comparison.
    
    Args:
        version: Version string, possibly with a 'v' prefix
        
    Returns:
        Normalized version string without 'v' prefix
    """
    if version and isinstance(version, str):
        # Remove 'v' prefix if present
        if version.startswith('v'):
            version = version[1:]
        
        # Remove any trailing non-numeric parts (like -beta, -rc1, etc.)
        version = re.sub(r'[-+].*$', '', version)
        
    return version


def compare_versions(github_version, changelog_version):
    """
    Compare two version strings.
    
    Args:
        github_version: Version string from GitHub tag
        changelog_version: Version string from changelog
        
    Returns:
        -1 if github_version < changelog_version
         0 if github_version == changelog_version
         1 if github_version > changelog_version
    """
    if not github_version or not changelog_version:
        return None
    
    # Normalize versions for comparison
    github_version = normalize_version(github_version)
    changelog_version = normalize_version(changelog_version)
    
    # Split versions into components
    github_parts = github_version.split('.')
    changelog_parts = changelog_version.split('.')
    
    # Compare each component
    for i in range(max(len(github_parts), len(changelog_parts))):
        # If we've reached the end of one version, the longer one is newer
        if i >= len(github_parts):
            return -1  # GitHub version is shorter, so older
        if i >= len(changelog_parts):
            return 1   # Changelog version is shorter, so GitHub is newer
        
        # Convert to integers if both parts are numeric
        g_part = github_parts[i]
        c_part = changelog_parts[i]
        
        if g_part.isdigit() and c_part.isdigit():
            g_part = int(g_part)
            c_part = int(c_part)
        
        # Compare the current component
        if g_part < c_part:
            return -1
        if g_part > c_part:
            return 1
    
    # If we get here, versions are equal
    return 0


def fetch_github_tags(github_url):
    """
    Fetch tags from GitHub with full pagination.
    
    Args:
        github_url: GitHub repository URL
        
    Returns:
        Dictionary with tag information or error
    """
    if not github_url or not github_url.startswith('https://github.com/'):
        return {'has_tags': False, 'reason': 'Invalid GitHub URL'}
    
    # Extract owner and repo from GitHub URL
    parts = github_url.rstrip('/').split('/')
    if len(parts) < 5:
        return {'has_tags': False, 'reason': 'Invalid GitHub URL format'}
    
    owner = parts[-2]
    repo = parts[-1]
    
    # Get all tags with pagination
    all_tags = []
    page = 1
    per_page = 100
    
    try:
        while True:
            api_url = f'https://api.github.com/repos/{owner}/{repo}/tags?page={page}&per_page={per_page}'
            response = requests.get(api_url)
            
            if response.status_code != 200:
                return {'has_tags': False, 'reason': f'API error: {response.status_code}'}
                
            tags_page = response.json()
            if not tags_page:
                break
                
            all_tags.extend(tags_page)
            
            if len(tags_page) < per_page:
                break
                
            page += 1
            # Add a small delay to avoid rate limiting
            time.sleep(0.2)
        
        if all_tags:
            # Filter for version tags
            version_tags = [tag['name'] for tag in all_tags if is_version_tag(tag['name'])]
            
            if version_tags:
                return {
                    'has_tags': True,
                    'has_version_tags': True,
                    'latest_version_tag': version_tags[0]
                }
            else:
                return {
                    'has_tags': True,
                    'has_version_tags': False,
                    'reason': 'No version tags found'
                }
        else:
            return {'has_tags': False, 'reason': 'No tags found'}
    except Exception as e:
        return {'has_tags': False, 'reason': f'Error: {str(e)}'}


def check_updates(projects, pkg_specs_dir):
    """
    Check for available updates by comparing GitHub tags with changelog versions.
    
    Args:
        projects: List of project dictionaries from the projects table
        pkg_specs_dir: Path to the pkg_specs directory
        
    Returns:
        Dictionary with update status for each project
    """
    results = []
    
    for project in projects:
        project_name = project['project_name']
        source_name = project['source_name']
        github_url = project['github_url']
        
        # Fetch tags from GitHub
        tags_info = fetch_github_tags(github_url)
        has_version_tags = tags_info.get('has_version_tags', False)
        latest_version_tag = tags_info.get('latest_version_tag', '')
        
        # Skip projects without version tags
        if not has_version_tags:
            results.append({
                'project_name': project_name,
                'source_name': source_name,
                'has_version_tags': has_version_tags,
                'latest_version_tag': latest_version_tag,
                'changelog_version': None,
                'changelog_suffix': None,
                'update_available': False,
                'is_update_available': False,
                'status': 'No proper version tags available'
            })
            continue
        
        # Look for changelog file
        changelog_path = os.path.join(pkg_specs_dir, f"{project_name}.changelog")
        if not os.path.exists(changelog_path):
            # Try with source_name if project_name doesn't work
            changelog_path = os.path.join(pkg_specs_dir, f"{source_name}.changelog")
        
        if not os.path.exists(changelog_path):
            results.append({
                'project_name': project_name,
                'source_name': source_name,
                'has_version_tags': has_version_tags,
                'latest_version_tag': latest_version_tag,
                'changelog_version': None,
                'changelog_suffix': None,
                'update_available': False,
                'is_update_available': False,
                'status': 'Changelog file not found'
            })
            continue
        
        # Extract version from changelog
        changelog_version, changelog_suffix = extract_version_from_changelog(changelog_path)
        
        if not changelog_version:
            results.append({
                'project_name': project_name,
                'source_name': source_name,
                'has_version_tags': has_version_tags,
                'latest_version_tag': latest_version_tag,
                'changelog_version': None,
                'changelog_suffix': None,
                'update_available': False,
                'is_update_available': False,
                'status': 'Could not extract version from changelog'
            })
            continue
        
        # Compare versions
        comparison = compare_versions(latest_version_tag, changelog_version)
        
        if comparison is None:
            status = 'Could not compare versions'
            update_available = False
        elif comparison > 0:
            status = 'Update available'
            update_available = True
        elif comparison == 0:
            status = 'Up to date'
            update_available = False
        else:
            status = 'Changelog version is newer than GitHub tag'
            update_available = False
        
        results.append({
            'project_name': project_name,
            'source_name': source_name,
            'has_version_tags': has_version_tags,
            'latest_version_tag': latest_version_tag,
            'changelog_version': changelog_version,
            'changelog_suffix': changelog_suffix,
            'update_available': update_available,
            'is_update_available': update_available,
            'status': status
        })
    
    return results


def format_text_output(results):
    """
    Format results as human-readable text.
    
    Args:
        results: List of result dictionaries
        
    Returns:
        Formatted text output
    """
    output = []
    output.append("Version Checker Results (Live GitHub Tags)")
    output.append("========================================")
    output.append("")
    
    # Count updates
    updates_available = sum(1 for r in results if r['is_update_available'])
    output.append(f"Found {updates_available} projects with updates available")
    output.append("")
    
    # Projects with updates
    if updates_available > 0:
        output.append("Projects with updates available:")
        output.append("-------------------------------")
        for result in results:
            if result['is_update_available']:
                project_name = result['project_name']
                latest_tag = result['latest_version_tag']
                changelog_version = result['changelog_version']
                changelog_suffix = result['changelog_suffix']
                
                changelog_full = f"{changelog_version}-{changelog_suffix}" if changelog_suffix else changelog_version
                output.append(f"- {project_name}: {changelog_full} -> {latest_tag}")
        output.append("")
    
    # All projects status
    output.append("All Projects Status:")
    output.append("------------------")
    for result in results:
        project_name = result['project_name']
        status = result['status']
        
        if result['changelog_version']:
            changelog_version = result['changelog_version']
            changelog_suffix = result['changelog_suffix']
            changelog_full = f"{changelog_version}-{changelog_suffix}" if changelog_suffix else changelog_version
            version_info = f" (Changelog: {changelog_full}, GitHub: {result['latest_version_tag']})"
        else:
            version_info = ""
            
        output.append(f"- {project_name}: {status}{version_info}")
    
    return "\n".join(output)


def main():
    """Main function to run the version checker."""
    parser = argparse.ArgumentParser(description='Check for available updates in cryptoanarchy-deb-repo-builder projects')
    parser.add_argument('--json-output', action='store_true', help='Output results in JSON format')
    args = parser.parse_args()
    
    # Paths
    script_dir = os.path.dirname(os.path.abspath(__file__))
    repo_root = os.path.dirname(script_dir)
    projects_table_path = os.path.join(script_dir, 'data/projects_version_tags.csv')
    pkg_specs_dir = os.path.join(repo_root, 'pkg_specs')
    
    # Load projects data
    projects = load_projects_table(projects_table_path)
    
    # Check for updates
    results = check_updates(projects, pkg_specs_dir)
    
    # Output results
    if args.json_output:
        print(json.dumps(results, indent=2))
    else:
        print(format_text_output(results))


if __name__ == "__main__":
    main()
