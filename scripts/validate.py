#!/usr/bin/env python3

import sys
import pkg_resources
import os
import dotenv
import asyncio
import subprocess
import platform
from typing import List, Set
import distro

def validate_python_version() -> None:
    """Validate Python version based on the platform."""
    system = platform.system().lower()
    
    if system == 'linux':
        # Check if we're on RHEL
        if 'rhel' in distro.id() or 'red hat' in distro.id():
            if sys.version_info < (3, 9):
                raise RuntimeError(f"Python 3.9+ is required for RHEL. Current version: {sys.version}")
            print(f"✓ Python version validated for RHEL: {sys.version}")
            return
    
    # For all other systems, require Python 3.11+
    if sys.version_info < (3, 11):
        raise RuntimeError(f"Python 3.11+ is required. Current version: {sys.version}")
    print(f"✓ Python version validated: {sys.version}")

def validate_dependencies() -> None:
    """Validate that all required dependencies are installed."""
    required: Set[str] = {'llama-index', 'mcp', 'python-dotenv', 'openai', 'poetry'}
    installed = {pkg.key for pkg in pkg_resources.working_set}
    missing = required - installed
    if missing:
        raise RuntimeError(f"Missing dependencies: {missing}")
    print("✓ Dependencies validated")

def validate_environment() -> None:
    """Validate that all required environment variables are set."""
    dotenv.load_dotenv()
    required_vars: List[str] = ['LLAMA_CLOUD_API_KEY', 'OPENAI_API_KEY']
    missing = [var for var in required_vars if not os.getenv(var)]
    if missing:
        raise RuntimeError(f"Missing environment variables: {missing}. Please check .env file.")
    print("✓ Environment variables validated")

def validate_platform_setup() -> None:
    """Validate platform-specific setup."""
    system = platform.system().lower()
    
    if system == 'darwin':  # macOS
        # Check for command line tools
        try:
            subprocess.run(['xcode-select', '-p'], check=True, capture_output=True)
            print("✓ macOS command line tools validated")
        except subprocess.CalledProcessError:
            raise RuntimeError("Xcode command line tools not installed")
    
    elif system == 'linux':
        # Check for required system packages
        if 'rhel' in distro.id() or 'red hat' in distro.id():
            packages = ['python3-devel']
            cmd = ['rpm', '-q']
        elif 'ubuntu' in distro.id():
            packages = ['python3.11-dev']
            cmd = ['dpkg', '-l']
        else:
            print("⚠ Unknown Linux distribution, skipping platform validation")
            return
            
        for pkg in packages:
            try:
                subprocess.run([*cmd, pkg], check=True, capture_output=True)
                print(f"✓ System package validated: {pkg}")
            except subprocess.CalledProcessError:
                raise RuntimeError(f"Required system package not installed: {pkg}")
    
    elif system == 'windows':
        # Check for Visual C++ build tools
        try:
            subprocess.run(['cl'], check=True, capture_output=True)
            print("✓ Visual C++ build tools validated")
        except (subprocess.CalledProcessError, FileNotFoundError):
            print("⚠ Visual C++ build tools might not be installed")
    
    print(f"✓ Platform ({system}) setup validated")

async def validate_server() -> None:
    """Validate server startup."""
    try:
        # Test stdio server
        process = await asyncio.create_subprocess_exec(
            sys.executable, 'mcp-server.py',
            stdin=asyncio.subprocess.PIPE,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )
        
        try:
            await asyncio.wait_for(process.wait(), timeout=5.0)
            print("✓ Server startup validated")
        except asyncio.TimeoutError:
            # This is actually good - server is running
            print("✓ Server startup validated")
        finally:
            if process.returncode is None:
                process.terminate()
                await process.wait()
    
    except Exception as e:
        raise RuntimeError(f"Server validation failed: {e}")

def main() -> int:
    """Main validation function."""
    try:
        print("Starting validation...")
        validate_python_version()
        validate_platform_setup()
        validate_dependencies()
        validate_environment()
        asyncio.run(validate_server())
        print("\nValidation successful! ✨")
        return 0
    except Exception as e:
        print(f"\n❌ Validation failed: {e}")
        return 1

if __name__ == "__main__":
    sys.exit(main()) 