# Notes on this Project

## Outline of Design Considerations

### Directory Structure

* **Group by Functionality**:
  Organize your scripts into directories based on their functionality or purpose.
  * For instance, you could have directories like networking,
    file_operations, system_monitoring, etc.
* **Common Library**:
  Have a directory for common functions that are used across various scripts.
  * This can be named something like lib or common.

### Script Naming and Organization

* **Naming Convention**:
  * Use a consistent naming convention for your scripts.
  * For instance, you might prefix scripts with their category...
    * *(e.g., net-checkconnection.sh, file-cleanlogs.sh)*.
* **Script Headers**:
  * Start each script with a commented header section describing its purpose,
    usage, and any dependencies.

### Code Reusability and the DRY Principle

* **Common Functions**:
  * Identify common tasks across your scripts and abstract them into
    functions stored in your common library.
* **Source Common Scripts**:
  * Use the source or `.` command to include these common functions in your scripts.
  * For example, source `/path/to/lib/common.sh`.

### Handling the PATH Issue

* **Local PATH Extension**:
  * Temporarily extend the PATH variable within your scripts to include
    your script directories.
  * This is done by export `PATH=$PATH:/path/to/your/script_directory`.
* **Permanent PATH Extension**:
  * For scripts that need to be globally accessible...
    * ...consider adding their directory to
      the `PATH` in your `.bashrc` or `.bash_profile`.

>**Note:** This is problematic because we're going for a directory hierarchy.
> Need to figure out how to do this without having to add each directory to `PATH`.
> For now we're going with a simple `SHALLADIR` variable to prefix commands.

### Testing and Maintenance

* **Modular Testing**:
  * Write tests for individual scripts and functions.
    * This ensures that changes in one part don't break another.
* **Version Control**:
  * Use a version control system like Git to manage changes and
    keep track of different versions.

### Documentation

* **README Files**:
  * Have a README file in each directory explaining the scripts contained and
    their purpose.
* **Inline Comments**:
  * Comment your code well to explain why you are doing something,
    not just what you are doing.

### Execution and Permissions

* **Executable Bit**:
  * Ensure your scripts have the executable bit set with `chmod +x scriptname.sh`.
* **Shebang Line**:
  * Start each script with a shebang line *(e.g., `#!/bin/bash`)*
    * This specifies the interpreter and gives programs a set of magic numbers to
      know what this file is.

### Packaging and Distribution

* **Install Scripts**:
  * Consider writing an installation script that:
    * Sets up the necessary environment
    * `PATH` changes
    * Permissions.
* **Packaging for Distribution**:
  * If you plan to distribute your scripts...
    * ...consider packaging them in a way that
      makes installation easy for the end user.

### Scalability and Enhancements

* **Scalability**:
  * Design your scripts and directory structure with scalability in mind.
  * It should be easy to add new categories or common functions.
* **Feedback and Iteration**:
  * Regularly review your scripts for...
    * Potential improvements.
    * Refactor when necessary.
