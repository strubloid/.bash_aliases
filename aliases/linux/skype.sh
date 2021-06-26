#!/bin/bash

# Strubloid::linux::skype

# how to fix skype
# W: An error occurred during the signature verification. The repository is not updated and the previous index files will be used. GPG error: https://repo.skype.com/deb stable InRelease: The following signatures were invalid: EXPKEYSIG 1F3045A5DF7587C3 Skype Linux Client Repository <se-um@microsoft.com>
# W: Failed to fetch https://repo.skype.com/deb/dists/stable/InRelease  The following signatures were invalid: EXPKEYSIG 1F3045A5DF7587C3 Skype Linux Client Repository <se-um@microsoft.com>
# W: Some index files failed to download. They have been ignored, or old ones used instead.
fixSkypeGPGKey () {
    curl https://repo.skype.com/data/SKYPE-GPG-KEY | sudo apt-key add -
}
