# zfs-addons
Various ZFS addons in development

Directories:
* bash-examples - some bash examples to use as a reference for creating a generic bash template file.
* bin           - scripts under development 
* licenses      - a collection of various LICENSE files for reference
* sanoid        - important text and md files from the sanoid project
* zfs           - important text and md files from the zfs project

Standard text and md files:

* AUTHORS
* CODE_OF_CONDUCT.md
* CONTRIBUTING.md
* COPYRIGHT
* LICENSE
* NOTES.md
* NOTICE
* README.md
* RELEASES.md

Projects under development:

* 'zfs-last-snap.bash' - select through local zfs pool filesystems and display the first and last snapshot on record, along with number of snapshots.
* 'mergoid.bash'       - merge several zfs filesystems that have similar file data set (i.e., missing snapshots in two similar datasets, merge into one)
* 'zfilter.bash'       - review a zfs filesystem, removing any unwanted/undesired folders or files in snapshots.
* 'snapoid.bash'       - snap refined clean up according to specified parms  (or even /etc/sanoid.conf ? )
  * i.e., sanoid will only remove snapshots if the snapshot is older than N of snaps to keep, multiplying the time period.
  * I want to trim out any repetitive snapshots. For example, several '_yearly' or '_monthly' snapshots in a month after some extra snapshots are created.
