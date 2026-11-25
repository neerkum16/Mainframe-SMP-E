# SMP/E Course Curriculum

## Course Modules

### SMP/E Overview
- What is System Modification Program Extended?
- What makes a product?
- SMP/E elements
- How products are packaged
- System modifications
- SMP/E database
- Receiving a SYSMOD
- Applying, accepting and restoring a SYSMOD
- System Generation
- Consolidated Software Inventory
- CSI configuration option
- Invoking SMP/E

### RECEIVE Processing
- The RECEIVE process
- Modification Control Statements
- MCS: header statement functions, software environment statement
- The Global Zone definition entry
- GZONE entry example
- Global Zone options entry
- options entry example
- Global Zone utility entry
- Utility entry example
- SMP/E allocation
- Global Zone DDDEF entry
- DDDEF entry example
- Review of Global Zone entries
- Creating Global Zone entries – UCLIN
- Relative file packaged tapes
- Receive processing
- Global Zone sysmod entry example
- Exception sysmods
- Held sysmod entry example
- Holdddata example
- tTe RECEIVE command
- Sysmod entry with SOURCEID example
- REPORT SOURCEID output examples
- SMP/E dialogs primary option menu & query selection menus

### APPLY Processing
- Product function & Installation methods
- Target Zone definition entry
- TZONE entry example
- Target Zone DDDEF entry
- Target Zone DDDEF entry example
- MAC, SRC, and MOD element MCS
- Data Element MCS
- Program Element MCS
- Identifying the target system structure
- How JCLIN processing works
- JCLIN processing example
- JCLIN report example
- JCLIN - MAC and ASSEM entries
- JCLIN - MOD and LMOD entries
- JCLIN - DLIB entries
- Invoking JCLIN
- The save control dataset
- Determining target libraries
- Apply processing
- Concatenating macro libraries for assemblies
- SYSLIB DDDEF example
- The APPLY command
- Target Zone SYSMOD entry example
- Element service level
- Target Zone MAC and SRC element entries
- Target Zone MOD and DATA element entries
- Base and dependent functions revisited
- Replacing an existing product
- Sysmod installation via the SMP/E dialog
- SMP/E dialogs - sysmod management options

### ACCEPT Processing
- Function installation methods
- Distribution Zone definition entry
- DZONE entry example
- Distribution Zone DDDEF entries
- Distribution Zone DDDEF entry example
- ACCEPT processing
- Concatenating macro libraries for assemblies
- The ACCEPT command
- Distribution Zone SYSMOD entry example
- Distribution Zone MAC and SRC element entries
- Distribution Zone MOD and DATA element entries
- Sysmod installation via the SMP/E dialogs
- SMP/E dialogs - sysmod management options

### Product Maintenance
- Product maintenance (service)
- Product maintenance sysmods
- Product maintenance sysmod naming convention
- Product maintenance +++VER statement
- Updating MAC and SRC elements
- Updating MOD (and LMOD) elements
- Sysmod relationships
- The prerequisite relationship
- The requisite relationship
- The supersede relationship
- The negative prerequisite relationship
- TZONE sysmod entries – examples
- Related APPLY command parameters
- Element service level
- Tracking the service level of an element
- Element entries - service level
- Exception sysmods
- Resolving error holds
- Resolving system holds
- The RELEASE MCS statement
- Maintenance exposure
- The REPORT ERROR SYSMODS command
- Sysmod regression
- Sysmod construction rules
- Managing regression
- Restore processing
- Concatenating macro libraries for assemblies
- The RESTORE command
- Sysmod relationships and restore
- Reject processing
- The REJECT command

### Additional SMP/E Features
- The conditional requisite relationship
- The REPORT CROSSZONE command
- Cross product 'borrowing' - the problem, the solution
- Cross zone 'borrowing' - the problem, the solution
- Callable services support
- Processing SYS1B in JCLIN
- CALLLIBS in LMOD element entries
- Installing LMODs that use CALLLIBS
- The zone management commands
- Installing SYSGEN and SMP/E products
- The GENERATE command
- The CLEANUP command
- Descriptive MCS statements
- Product and feature entries

### Installing Products and Service
- Reporting problems to the vendor
- Preparing for installation
- Installing maintenance
- Product delivery mechanisms used by IBM
- CustomPac service
- The Recommended Service Upgrade
- ShopzSeries
- PSP buckets
- HOLD FIXCAT
- Fix Categories
- Receiving FIXCAT HOLDS
- APPLY / ACCEPT FIXCAT operand
- REPORT MISSINGFIX command
