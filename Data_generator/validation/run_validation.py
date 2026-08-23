import glob
import subprocess
import os
import sys

# Ensure PYTHONPATH is set so modules are found correctly
project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), "../.."))
os.environ["PYTHONPATH"] = project_root

def main():
    val_dir = os.path.dirname(__file__)
    
    # Grab all test files matching Test_*.py
    test_files = sorted(glob.glob(os.path.join(val_dir, "Test_*.py")))

    if not test_files:
        print("No tests found.")
        sys.exit(1)

    print(f"Found {len(test_files)} validation tests. Executing sequentially...\n")

    total = len(test_files)
    passed_count = 0
    failed_tests = []

    for i, test_file in enumerate(test_files, 1):
        filename = os.path.basename(test_file)
        print(f"[{i}/{total}] Executing {filename}...")
        
        # Run the test
        result = subprocess.run(
            [sys.executable, test_file], 
            capture_output=True, 
            text=True,
            cwd=project_root # Run from project root so "Data/generated/clean" resolves correctly
        )
        
        # Print the output from the test so the user can see it
        print(result.stdout)
        
        if result.stderr:
            print("Errors/Warnings:")
            print(result.stderr)
            
        # Parse the output to determine if it passed or failed
        if "❌" in result.stdout or "FAILED" in result.stdout:
            failed_tests.append(filename)
        else:
            passed_count += 1

    # Print a final summary
    print("=" * 60)
    print("VALIDATION TEST SUITE SUMMARY")
    print("=" * 60)
    print(f"Total Tests: {total}")
    print(f"Passed:      {passed_count}")
    print(f"Failed:      {len(failed_tests)}")
    
    if failed_tests:
        print("\nTests with failures:")
        for failed in failed_tests:
            print(f" - {failed}")
        sys.exit(1)
    else:
        print("\nAll validation tests passed perfectly!")
        sys.exit(0)

if __name__ == "__main__":
    main()
