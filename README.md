# How to install this shell script?

* You must clone this repository, doing:
```
    $ git clone https://github.com/strubloid/.bash_aliases.git
```
* Now that we have the git project you need to enter into the .bash_aliases folder
```
    $ cd .bash_aliases
```
* After you entering the folder ".bash_aliases" you must run the first configuration
```
    $ chmod +x install.sh (only if necessary)
    $ ./install.sh
```
* The last configuration will be to upgrade all data
```
    $ chmod +x upgrade.sh (only if necessary)
    $ ./upgrade.sh
```
That's it, now it is installed a few good aliases for you, have fun =]

# How to add a new alias and upgrade the data o your Operational System?

## Folder Structure
* aliases/general = those are the main scripts that will run on any Operational System, if you create or edit any file in this folder all operational systems will get this alias
* aliases/[operational system]: this is a operational System folder, files in this folder will be loaded only for the current operational system that you are using
> Ex: if you want to add a new alias only for linux you will need to edit or create a file on aliases/linux/[alias file]

After you finish all the editions, you must update the bash_aliases doing:
```
  $ ./upgrade.sh
```
After those steps you will be able to see the changes in your terminal.
