import glob
import subprocess
import os
import sys

# Ensure PYTHONPATH is set so that the Data_generator module can be found
project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../.."))
os.environ["PYTHONPATH"] = project_root

def main():
    test_dir = os.path.dirname(__file__)
    # Find all test scripts
    test_files = sorted(glob.glob(os.path.join(test_dir, "test_*.py")))
    
    # Exclude the full integration test as it takes a while and is distinct from the unit tests
    test_files = [f for f in test_files if not f.endswith("test_full_injector.py")]

    total = len(test_files)
    passed = 0
    failed = []

    print(f"Found {total} unit tests. Starting execution...\n")

    for i, test_file in enumerate(test_files, 1):
        filename = os.path.basename(test_file)
        print(f"[{i}/{total}] Running {filename}...", end=" ", flush=True)
        
        result = subprocess.run([sys.executable, test_file], capture_output=True, text=True)
        
        if result.returncode == 0:
            print("✅ Passed")
            passed += 1
        else:
            print("❌ Failed")
            failed.append((filename, result.stderr))

    print("\n" + "="*40)
    print("TEST SUITE SUMMARY")
    print("="*40)
    print(f"Total Tests: {total}")
    print(f"Passed:      {passed}")
    print(f"Failed:      {len(failed)}")
    
    if failed:
        print("\nFailures:")
        for name, err in failed:
            print(f"\n--- {name} ---")
            print(err)
        sys.exit(1)
    else:
        print("\nAll tests completed successfully!")
        sys.exit(0)

if __name__ == "__main__":
    main()
