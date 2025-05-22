# File generator for CISCO phones
This script helps one to make CISCO phones work without CUCM crap. 
It generates needed files based on an information provided, such as: phone's *MAC address*, *model* and *Asterisk*'s registration details together with it's IP.
The script now supports only **CP-8841** or **CP-7821** models, but you may add another by copying a template named *source\<model number\>.cnf.xml*. Note, that script modification is needed in this case.

## Requirements
- working and tuned tftp server with:  
	- **\\tftp\\** as a root directory (*tftpd-hpa* is recommended)
	- user *tftp* with *rw* access to **\\tftp\\**
- privileged user to run the script
## Usage
`#./cisconf.sh <model> <extension> <password> <MAC address> <Asterisk's IP>`
- model - CP-8841 or CP-7821.
- extension - can be 3 or 4 digits.
- MAC must be with colons -> :

Example:
`#./cisconf.sh 8841 112 p@ssWord 01:70:31:71:76:1D 10.10.1.100`
