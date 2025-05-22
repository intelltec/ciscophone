# File generator for CISCO phones
This script helps one to make CISCO phones work without CUCM crap. 
It generates needed files based on an information provided, such as: phone's *MAC address*, *model* and *Asterisk*'s registration details together with it's IP.
The script now supports only **CP-8841** or **CP-7821** models, but you may add another by copying a template named *source\<model number\>.cnf.xml*. Note, that script modification is needed after that.

## Requirements
- working and tuned tftp server with:  
	- **\\tftp\\** as a root directory (*tftpd-hpa* is recommended)
	- user *tftp* with *rw* access to **\\tftp\\**
- privileged user to run the script 
