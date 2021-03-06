# Purpose

This JavaScript provides functionality similar to a 'view state' for various pages in the Checkmarx Web Portal. This has been tested on versions 8.8, 9.0, 9.2, and 9.3.
It functions by hooking into the process that changes how table contents are changed - such as applying filter settings, changing the pagination, and changing the column sorting.
These state-changes are stored in the URL after the '#' character, so the view state is persisted client-side. When a page using this JavaScript loads, it reads this view state from the URL and re-applies the necessary steps to recreate the desired view.

These modifications are not supported by Checkmarx. Future releases of Checkmarx or patches/hotfixes may revert any custom modification of the Checkmarx installed files, thus these modifications may need to be re-implemented after every update of the environment. Future releases of Checkmarx may also break these changes, no guarantee is made regarding compatibility or future maintenance of this functionality.  

# Installation

To install and use this script, copy the TableSort.js file into your Checkmarx installation's CheckmarxWebPortal\Web\ folder.
To apply the functionality for a specific page, two changes are required. The instructions below apply to Checkmarx version 9.2, and this example is using the ProjectState.aspx page.

## Load TableSort.js

The start of each page in the Web Portal is similar to the following:

``` HTML
<asp:Content ID="cnt1" ContentPlaceHolderID="head" runat="Server">
   <script language="javascript" type="text/javascript">
       var toolbarBtn = null;
```
(Original lines 6, 7, and 8 of ProjectState.aspx)

The TableSort.js file must be included at the start, after any server-side includes:

``` HTML
<asp:Content ID="cnt1" ContentPlaceHolderID="head" runat="Server">
    <script src="TableSort.js" type='text/javascript' language='javascript'></script>
    <script language="javascript" type="text/javascript">
        var toolbarBtn = null;
```
(Modified: A new Line 7 has been added)


## Add the event hooks

Two functions are used within the TableSort.js file to capture client-side events: MTVCreated and GridCommand. They must be added to the target table's ClientSettings block.

``` HTML
<ClientSettings ReorderColumnsOnClient="True" AllowDragToGroup="True" AllowColumnsReorder="True"
    AllowGroupExpandCollapse="true">
    <Resizing AllowRowResize="false" AllowColumnResize="True" EnableRealTimeResize="True"
        ResizeGridOnColumnResize="False"></Resizing>
    <Selecting AllowRowSelect="true" />
</ClientSettings>
```
(Original lines 168-173 of ProjectState.aspx)

``` HTML
<ClientSettings ReorderColumnsOnClient="True" AllowDragToGroup="True" AllowColumnsReorder="True"
    AllowGroupExpandCollapse="true">
    <Resizing AllowRowResize="false" AllowColumnResize="True" EnableRealTimeResize="True"
        ResizeGridOnColumnResize="False"></Resizing>
    <Selecting AllowRowSelect="true" />
    <ClientEvents OnMasterTableViewCreated="MTVCreated" />                    
    <ClientEvents OnCommand="GridCommand" />
</ClientSettings>
```
(Modified: Two new ClientEvents added to call the MTVCreated and GridCommand functions)

# Checkmarx 9.3
In the Cx9.3 folder, the original versions as well as modified versions of the Projects.aspx, ProjectState.aspx, and Scans.aspx files have been provided. These files are based on the Cx9.3 release version. It is possible that hotfixes released since the 9.3 release may change these files, in which case the manual instructions above should be followed and should be tested in a test environment prior to deployment.


# Compatibility

This script was originally written for Checkmarx 8.8 and should be compatible up to Checkmarx 9.2.
It has been tested to function on the following pages:
* ProjectState.aspx
* Projects.aspx
* ProjectScans.aspx
* Scans.aspx
* UserManagement.aspx (8.x)