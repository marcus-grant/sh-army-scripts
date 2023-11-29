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

## Approaches to Common Entrypoint to Script

Creating a collection of reusable Bash scripts that can be easily called from
the command line, similar to a utility library like lodash, is a great idea.
To achieve this without placing all scripts in
a flat directory and modifying the `PATH`, you can consider a few approaches:

### 1. Structured Directory with a Central Dispatcher Script

* **Directory Structure**:
  * Organize your scripts into a structured directory.
  * Group them by functionality or purpose.

* **Dispatcher Script**:
  * Create a central dispatcher or launcher script at
    the root of this structure.
  * This script can call other scripts based on input parameters.

* **Example**:

  ```bash
  mytools.sh file clean  # Calls the 'clean' script in the 'file' category
  ```

* **Advantages**: This approach keeps your script organization clean and allows easy expansion. It also avoids cluttering the `PATH`.

### 2. Sourcing Scripts from a Common Entry Point

* **Common Entry Point**:
  * Have a main script that sources other scripts.
  * This main script can be the only one in your `PATH`.

* **Sourcing**:
  * The main script sources other scripts as needed.
  * These scripts can be organized in a structured directory hierarchy.

* **Example**:

  ```bash
  # In main.sh
  source "${SCRIPT_ROOT}/utils/file_operations.sh"
  ```

* **Advantages**:
  * This method allows for modular script organization and
    keeps the global namespace clean.

### 3. Creating Aliases or Shell Functions

* **Aliases/Functions**:
  * In your `.bashrc` or `.bash_profile`,
    create aliases or functions that point to your scripts.

* **Example**:

  ```bash
  alias clean_files='/path/to/scripts/file_operations/clean.sh'
  ```

* **Advantages**:
  * Easy to set up and use,
    but can become unmanageable with a large number of scripts.

### 4. Using Symbolic Links in a Bin Directory

* **Symbolic Links**: Create symbolic links to your scripts in a directory that is in your `PATH`.

* **Example**:

  ```bash
  ln -s /path/to/scripts/file_operations/clean.sh /usr/local/bin/clean_files
  ```

* **Advantages**: Keeps the scripts organized in their original location while making them accessible from anywhere.

### 5. Packaging Scripts as a Shell Library

* **Shell Library**: Package your scripts as a shell library, which can be sourced in other scripts or interactive shells.

* **Example**:

  ```bash
  source '/path/to/mylib.sh'
  ```

* **Advantages**: Similar to sourcing scripts, but more formalized and easier to distribute or share.

### Conclusion

Each of these methods has its advantages and can be suited to different scenarios. The best choice depends on factors like the number of scripts, their complexity, and how you intend to use them. For ease of use and scalability, a structured directory with a central dispatcher script or a shell library approach might be most effective.
