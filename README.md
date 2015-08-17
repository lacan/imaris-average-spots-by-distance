# imaris-average-spots-by-distance

This XTension takes in a spots object and a distance value and returns a new spots object with spots closer than the given distance removed averaged to a single spot.

# Download

Just download the latest version [https://github.com/lacan/imaris-average-spots-by-distance/releases/tag/v1.0 here] or on [Imaris Open]

# Install

Like all Imaris XTensions, the .m file simply needs to be placed into the 'XT\matlab' folder.

# Running

The XTension is under '''Images->Spots Functions''' and is called ''Average Spots By Distance'' 

# Special Notes

This XTension can be used outside of the Imaris menus, simply call
```
XTSpotsAverageByDistance(aImarisApplication, distance);
```
where `aImarisApplication` is either the ID to the Imaris application or an instance of `vImarisApplication`
and `distance` the distance that you want to use. 

Calling it this way does not cause a prompt to appear.
