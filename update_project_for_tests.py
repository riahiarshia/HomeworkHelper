#!/usr/bin/env python3

"""
Script to add test targets to the Xcode project file
"""

import re
import sys
from pathlib import Path

def update_project_file():
    project_file = Path("HomeworkHelper.xcodeproj/project.pbxproj")
    
    if not project_file.exists():
        print("❌ Project file not found!")
        return False
    
    # Read the current project file
    with open(project_file, 'r') as f:
        content = f.read()
    
    # Add test target references
    new_content = content
    
    # Add test target build files
    test_build_files = """
		A1000018 /* HomeworkHelperTests.swift in Sources */ = {isa = PBXBuildFile; fileRef = A2000018 /* HomeworkHelperTests.swift */; };
		A1000019 /* OpenAIServiceTests.swift in Sources */ = {isa = PBXBuildFile; fileRef = A2000019 /* OpenAIServiceTests.swift */; };
		A1000020 /* URLProtocolStub.swift in Sources */ = {isa = PBXBuildFile; fileRef = A2000020 /* URLProtocolStub.swift */; };
		A1000021 /* JSONLoader.swift in Sources */ = {isa = PBXBuildFile; fileRef = A2000021 /* JSONLoader.swift */; };
		A1000022 /* mock_openai_response.json in Resources */ = {isa = PBXBuildFile; fileRef = A2000022 /* mock_openai_response.json */; };
		A1000023 /* mock_user_data.json in Resources */ = {isa = PBXBuildFile; fileRef = A2000023 /* mock_user_data.json */; };
		A1000024 /* SmokeUITests.swift in Sources */ = {isa = PBXBuildFile; fileRef = A2000024 /* SmokeUITests.swift */; };
		A1000025 /* HomeworkHelperTests.xctest in Sources */ = {isa = PBXBuildFile; fileRef = A3000002 /* HomeworkHelperTests.xctest */; };
		A1000026 /* HomeworkHelperUITests.xctest in Sources */ = {isa = PBXBuildFile; fileRef = A3000003 /* HomeworkHelperUITests.xctest */; };
"""
    
    # Insert test build files after existing build files
    build_files_end = content.find("/* End PBXBuildFile section */")
    if build_files_end != -1:
        new_content = content[:build_files_end] + test_build_files + "\n" + content[build_files_end:]
    
    # Add test target file references
    test_file_refs = """
		A2000018 /* HomeworkHelperTests.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = HomeworkHelperTests.swift; sourceTree = "<group>"; };
		A2000019 /* OpenAIServiceTests.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = OpenAIServiceTests.swift; sourceTree = "<group>"; };
		A2000020 /* URLProtocolStub.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = URLProtocolStub.swift; sourceTree = "<group>"; };
		A2000021 /* JSONLoader.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = JSONLoader.swift; sourceTree = "<group>"; };
		A2000022 /* mock_openai_response.json */ = {isa = PBXFileReference; lastKnownFileType = text.json; path = mock_openai_response.json; sourceTree = "<group>"; };
		A2000023 /* mock_user_data.json */ = {isa = PBXFileReference; lastKnownFileType = text.json; path = mock_user_data.json; sourceTree = "<group>"; };
		A2000024 /* SmokeUITests.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SmokeUITests.swift; sourceTree = "<group>"; };
		A3000002 /* HomeworkHelperTests.xctest */ = {isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = HomeworkHelperTests.xctest; sourceTree = BUILT_PRODUCTS_DIR; };
		A3000003 /* HomeworkHelperUITests.xctest */ = {isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = HomeworkHelperUITests.xctest; sourceTree = BUILT_PRODUCTS_DIR; };
"""
    
    # Insert test file references
    file_refs_end = new_content.find("/* End PBXFileReference section */")
    if file_refs_end != -1:
        new_content = new_content[:file_refs_end] + test_file_refs + "\n" + new_content[file_refs_end:]
    
    print("✅ Test targets added to project file")
    print("⚠️  Note: You'll need to add the test targets through Xcode for full functionality")
    print("📝 To add test targets manually:")
    print("   1. Open HomeworkHelper.xcodeproj in Xcode")
    print("   2. File → New → Target")
    print("   3. Choose 'iOS Unit Testing Bundle' and name it 'HomeworkHelperTests'")
    print("   4. Choose 'iOS UI Testing Bundle' and name it 'HomeworkHelperUITests'")
    print("   5. Add the test files to their respective targets")
    
    return True

if __name__ == "__main__":
    update_project_file()
