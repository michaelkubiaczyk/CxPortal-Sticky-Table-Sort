<%@ Page Title="" Language="C#" MasterPageFile="~/MainMaster.master" AutoEventWireup="true" Inherits="ProjectsNew" CodeBehind="Projects.aspx.cs" %>
<%@ Register TagPrefix="CX" Assembly="CxWebClientApp" Namespace="CxControls" %>
<%@ Register Src="SourceFilterPatternControl.ascx" TagName="SourceFilterPatternControl" TagPrefix="CX" %>

<asp:Content ID="cnt1" ContentPlaceHolderID="head" runat="Server">
    <%= System.Web.Optimization.Scripts.Render("~/portal/Scripts/portal") %>
    <%= System.Web.Optimization.Scripts.Render("~/portal/Scripts/projects") %>
    <%= System.Web.Optimization.Scripts.Render("~/portal/Scripts/projectPolicies") %>
    <%= System.Web.Optimization.Scripts.Render("~/portal/Scripts/OsaSettings") %>
    <%= System.Web.Optimization.Scripts.Render("~/portal/Scripts/projectPublisher") %>
    <script src="TableSort.js" type='text/javascript' language='javascript'></script>

    <style type="text/css">

        .isProjectPoliciesMngInstalled{
            display:none;
        }

        fieldset {
            border: 1px solid #003366;
        }

        legend {
            padding: 0px 5px 0px 5px;
            margin-left: 20px;
            font-weight: 500;
            font-size: 10pt !important;
            color: #0066cc;
        }

        td {
            white-space: nowrap;
        }

        .white {
            background-color: #FDFDFD;
        }

        .rmpHiddenView {
            display: none !important;
        }

        .imGrid {
            float: right;
        }       

         .customField{
             padding-top: 5px;
             padding-bottom: 5px;
         }

         .customFieldNameLabel{
             width:100px;
             display:inline-block;
             overflow:hidden;
             white-space:nowrap;
             -ms-text-overflow:ellipsis;
             -o-text-overflow:ellipsis;
             text-overflow:ellipsis;             
             vertical-align: middle;
         }
        .ui-menu .ui-menu-item {
            font-size: 13px;
            font-weight: normal;
            max-width: 500px;
            -ms-text-overflow: ellipsis;
            -o-text-overflow: ellipsis;
            text-overflow: ellipsis;
            white-space: nowrap;
            overflow: hidden;
        }
         
        .ui-menu .ui-menu-item a {
            max-width:500px;
            display:inline-block;
            -ms-text-overflow:ellipsis;
            -o-text-overflow:ellipsis;
            text-overflow:ellipsis;
            white-space:nowrap;     
            overflow:hidden; 
        }
         
        .ui-autocomplete.ui-widget-content{
            background: #ffffff url("app/libs/jquery-ui/css/images/ui-bg_flat_75_ffffff_40x100.png") 50% 50% repeat-x;
        }
        .customFieldValue {
            width:160px;
        }

        .ui-autocomplete .ui-menu-item.ui-state-focus{
            background: #dadada url("app/libs/jquery-ui/css/images/ui-bg_glass_75_dadada_1x400.png") 50% 50% repeat-x;
        }

        .unavailableAction{
            visibility:hidden;
        }

        .availableAction{
            visibility:visible;
        }

        #osaProjectPolicies{
            margin:15px 0;
            padding-top:25px;
            border-top:1px solid lightgray;
        }

        .policyStaticSync{
            background: url(Images/Icons/staticSync.png) 
            left 9px top 3px no-repeat;
            background-size: 15px 15px;
            height:25px;
            background-color: #e7e7e7;
            padding-left: 32px;
            padding-right:24px;
            border-radius: 4px;
            cursor: pointer;
        }

        .policyStaticSync:hover {
            background-color: #C8C8C8;
        }

        .policyDynamicSync{
            background: url(Images/Icons/dynamicSync.gif) 
            left 7px top 2px no-repeat;
            background-size: 17px 17px;
            min-width: 86px;
            height:25px;
            background-color: #e7e7e7;
            padding-left: 29px;
            border-radius: 4px;
            outline:0 !important;
        }

        .policySyncPanelWithScan{
            height:200px;
            width:320px;
        }

        .policySyncPanelWithNoScan{
            height:165px;
        }
         
    </style>
    <script src="app/libs/SignalR/jquery.signalR-2.3.0.js" type="text/javascript"></script>
    <script language="javascript" type="text/javascript">
        var emailsType = null;
        var EmailsMaxLength = <%=CxPortalSettings.Default.EmailsMaxLength%>;
        var EmailMaxCount = <%=CxPortalSettings.Default.EmailMaxCount%>;
        var SingleMailMaxLength = <%=CxPortalSettings.Default.SingleMailMaxLength%>;
        var EmailsMaxLengthError = '<%=CxPortalSettings.Default.SingleMailMaxLength%>';
        var EmailMaxCountError = '<%=GetTermFromResourceJsEncoded("EMAILMAXCOUNTERROR") %>';
        var SingleMailMaxLengthError = '<%=GetTermFromResourceJsEncoded("SINGLEMAILMAXLENGTHERROR") %>';
        var InvalidEmailError = '<%=GetTermFromResourceJsEncoded("INVALIDEMAIL") %>';
        var ConfirmMessage = '<%=GetTermFromResourceJsEncoded("CONFIRMCANCELPROJECTWIZARD") %>';
        var ConfirmChangingSourceToLocal = '<%=GetTermFromResourceJsEncoded("CONFIRM_CHANGE_SOURCE_LOCATION_TO_LOCAL") %>';
        var ConfirmChangingSourceFromLocal = '<%=GetTermFromResourceJsEncoded("CONFIRM_CHANGE_SOURCE_LOCATION_FROM_LOCAL") %>';
        var ConfirmChangingSourceLocationOSA = '<%=GetTermFromResourceJsEncoded("CONFIRM_CHANGE_SOURCE_LOCATION_OSA") %>';
        var ConfirmLeavingPageLossOfChanges = '<%=GetTermFromResourceJsEncoded("LEAVING_PAGE_LOSS_OF_CHANGES_WARNING") %>';

        var DELETE_PROJECTS_SUCCESSFULLY = '<%=this.GetTermFromResourceJsEncoded("DELETE_PROJECTS_SUCCESSFULLY")%>';
        var DELETE_PROJECTS_PARTLY_SUCCESSFUL = '<%=this.GetTermFromResourceJsEncoded("DELETE_PROJECTS_PARTLY_SUCCESSFUL")%>';
        var DELETE_SCANS_DOWNLOAD_FILE = '<%=this.GetTermFromResourceJsEncoded("DELETE_SCANS_DOWNLOAD_FILE")%>';
        var DELETE_SCANS_DOWNLOAD_TEXT = '<%=this.GetTermFromResourceJsEncoded("DELETE_SCANS_DOWNLOAD_TEXT")%>';
        var OK = '<%=this.GetTermFromResourceJsEncoded("OK")%>';
        var PUBLISH_SCAN_RESULTS_CONFIRMATION = "<%=this.GetTermFromResourceJsEncoded("PUBLISH_SCAN_RESULTS_CONFIRMATION")%>";

        var PUBLISH = '<%=GetTermFromResourceJsEncoded("PUBLISH")%>';
        var PUBLISHED = '<%=GetTermFromResourceJsEncoded("PUBLISHED")%>';
        var IN_PROGRESS = '<%=GetTermFromResourceJsEncoded("IN_PROGRESS")%>';
        var UNPUBLISHED ='<%=GetTermFromResourceJsEncoded("UNPUBLISHED")%>';
        var STATUS ='<%=GetTermFromResourceJsEncoded("STATUS")%>';
        var LAST_SUCCESSFUL_PUBLISH = '<%=GetTermFromResourceJsEncoded("LAST_SUCCESSFUL_PUBLISH")%>';
        var FINISHED = '<%=GetTermFromResourceJsEncoded("FINISHED")%>';
        var FAILED = '<%=GetTermFromResourceJsEncoded("FAILED")%>';
        var PUBLISH_SCAN_RESULTS_CONFIRMATION = "<%=this.GetTermFromResourceJsEncoded("PUBLISH_SCAN_RESULTS_CONFIRMATION")%>";
        var NEVER="<%=this.GetTermFromResourceJsEncoded("NEVER")%>";


        //--------------------------Publisher Status Sync Hub--------------------------//
        var initialize = function () {

            var connection = $.hubConnection(Core.REST.getRestBaseUrl() + Core.REST.restUrlPrefix + "signalr", { useDefaultPath: false });

            this.proxy = connection.createHubProxy('PublisherStatusSyncHub');

           // Listen to the 'UpdateStatus' event that will be pushed from SignalR server
            this.proxy.on('UpdateStatus', function (projectId,status,finishedDate) {
                var currentProjectId = $get("<%=hdnSelectedProject.ClientID%>").value;
                if (projectId == currentProjectId) {
                    updateDataBystatus(status,finishedDate);
                }
            });

            // Connecting to SignalR server        
            return connection.start({ transport: 'longPolling' })
            .then(function (connectionObj) {
                sendProjectIdToHub();
                return connectionObj;
            }, function (error) {
                return error.message;
            });

        };

        initialize();


        var sendProjectIdToHub = function() {
            var currentProjectId = $get("<%=hdnSelectedProject.ClientID%>").value;
            if (currentProjectId!=="") {
                this.proxy.invoke("updateProjectId", currentProjectId);
            }
        }


        //----------------------End Publisher Status Sync Hub---------------------------//

        /* --------------------------------------------------------------
         *                   - Osa project policies -
         * ------------------------------------------------------------*/

        var arePoliciesDirty = false;
        var osaSettingsDirty = false;
        //load OSA settings
        function loadOsaSettings() {
            var currentProjectId = $get("<%=hdnSelectedProject.ClientID%>").value;
            if (currentProjectId) {
                cxOsaSettings.getProjectSettings(currentProjectId,
                    function (response) {
                        if (response) {
                            showOSATabContent(response.enableOsaScanResolveDependencies);
                        } else {
                            showOSATabEulaNotAcceptedContent();
                        }
                    });
            }
        }

        function showOSATabContent(resolveDependenciesCheckboxDefaultValue) {
            $get("<%=divOSATabSpinner.ClientID%>").style.display = "none";
            $get("<%=disOSATabEulaNotAccepted.ClientID%>").style.display = "none";
            $get("<%=divOSATab.ClientID%>").style.display = "";
            $("#enableOsaResolveDependencies").prop('checked', resolveDependenciesCheckboxDefaultValue);
        }

        function showOSATabEulaNotAcceptedContent() {
            $get("<%=divOSATabSpinner.ClientID%>").style.display = "none";
            $get("<%=divOSATab.ClientID%>").style.display = "none";
            $get("<%=disOSATabEulaNotAccepted.ClientID%>").style.display = "";
        }

        function setOsaSettingsChecked() {
            osaSettingsDirty = true;
        }

        function updateOsaSettings() {
            var resolveDependencies = $("#enableOsaResolveDependencies").prop('checked');
            var osaSettings = {
                enableOsaScanResolveDependencies: resolveDependencies
            };
            var currentProjectId = $get("<%=hdnSelectedProject.ClientID%>").value;
            cxOsaSettings.updateProjectSettings(currentProjectId,
                osaSettings,
                function failedToUpdateSettings() {
                    //  $("#ctl00_cpmain_lblProjectGeneralError").
                });
        }

        // load policies
        function loadPolicies() {
            var listComboBox = $find("<%= cmbProjectPolicies.ClientID %>");
            var currentProjectId = $get("<%=hdnSelectedProject.ClientID%>").value;
            var lblFailedToLoadPolicies = $("#<%= lblFailedToLoadPolicies.ClientID %>");
            var lblFailedToUpdatePolicies = $("#<%= lblFailedToUpdatePolicies.ClientID %>");
            loadPoliciesData(listComboBox, true, currentProjectId, lblFailedToLoadPolicies, lblFailedToUpdatePolicies);
        }

        /* --------------------------------------------------------------
         *                  END - Osa project policies -
         * ------------------------------------------------------------*/


        function OpenEmailDialog(i_Type) {
            var url = "popEmailsDialog.aspx?emails=";
            if (i_Type == 1) {
                url += $get("<%=txtAfterScanSucceds.ClientID%>").value;
            } else if (i_Type == 2) {
                url += $get("<%=txtBeforeStartScan.ClientID%>").value;
            } else {
                url += $get("<%=txtScanFailed.ClientID%>").value;
            }

            var oWnd = radopenExt(url, null);
            emailsType = i_Type;
            oWnd.SetSize(450, 440);
            oWnd.Center();
            oWnd.add_close(EmailsDialogClosed);
        }

        function EmailsDialogClosed(Wnd, args) {
            var arg = args.get_argument();
            if (arg) {
                if (!arg.canceled) {
                    if (emailsType == 1) {
                        $get("<%=txtAfterScanSucceds.ClientID%>").value = arg.Emails;
                } else if (emailsType == 2) {
                    $get("<%=txtBeforeStartScan.ClientID%>").value = arg.Emails;
                } else {
                    $get("<%=txtScanFailed.ClientID%>").value = arg.Emails;
                    }
                }
            }
        }

        function OpenPullingDialog() {
            var combo = $find("<%= cmbGroup.ClientID %>");
            var val = combo.get_value(); // getting the selected value
            var oWnd = radopenExt("popCredentialsDialog.aspx?op=2&TeamId=" + val, null);
            oWnd.SetSize(410, 230);
            oWnd.Center();
            oWnd.add_close(OpenPullingDialogClosed);
        }

        function OpenPullingDialogClosed(Wnd, args) {
            var arg = args.get_argument();
            if (arg) {
                if (!arg.canceled) {
                    setTimeout(function () {
                        var combo = $find("<%= cmbGroup.ClientID %>");
                        var val = combo.get_value(); // getting the selected value
                        var oWnd = radopenExt("popSourcePullingDialog.aspx?TeamId=" + val, null);
                        oWnd.SetSize(430, 450);
                        oWnd.Center();
                        oWnd.add_close(PullingClosed);
                    }, 0);
                }
            }
        }

        function PullingClosed(Wnd, args) {
            var arg = args.get_argument();
            if (arg) {
                if (!arg.canceled) {
                    $get("<%=txtPulling.ClientID%>").value = arg.pathlist;
                }
            }
        }

        function OpenSourceControlDialog() {
            var oWnd = radopen("popSourceControlSettingsDialog.aspx?Mode=Update"
                + "&Port=" + $get('<%=PortHiddenField.ClientID%>').value
                  + "&ServerName=" + encodeURIComponent($get('<%=ServerNameHiddenField.ClientID%>').value)
                  + "&Repository=" + encodeURIComponent($get('<%=RepositoryHiddenField.ClientID%>').value)
                  + "&CollaboratorAuthenticationMethod=" + $get('<%=HiddenGitHubCollaboratorAuthenticationMethod.ClientID%>').value
                  + "&CollaboratorUserName=" + $get('<%=HiddenGitHubCollaboratorUserName.ClientID%>').value
                  + "&OwnerAuthenticationMethod=" + $get('<%=HiddenGitHubOwnerAuthenticationMethod.ClientID%>').value
                  + "&OwnerUserName=" + $get('<%=HiddenGitHubOwnerUserName.ClientID%>').value
                  + "&ThresholdValue=" + $get('<%=HiddenGitHubThreshold.ClientID%>').value
                  + "&ProjectId=" +currentProjectId, null);
            oWnd.SetSize(535, 446);
            oWnd.Center();
            oWnd.add_close(SourceControlSettingsClosed);
        }

        function SourceControlSettingsClosed(Wnd, args) {
            var arg = args.get_argument();
            if (arg) {
                if (!arg.canceled) {
                    setTimeout(function () {
                        var oWnd = radopenExt('popFoldersTree.aspx?Type=<%=BrowseTreeType.SourceControl%>&BrowseOrigin=<%=BrowseOrigin.SourceControl%>', null);
                        oWnd.SetSize(450, 470);
                        oWnd.Center();
                        oWnd.add_close(SourceControlClosed);
                    }, 0);
                }
            }
        }

        function SourceControlClosed(Wnd, args) {
            var arg = args.get_argument();
            if (arg) {
                if (!arg.canceled) {
                    $get("<%=txtSourceCtrl.ClientID%>").value = arg.pathList;
                    $get("<%=txtSCUrl.ClientID%>").value = arg.url;
                }
            }
        }

        function OpenSharedSourceDialog() {
            var oWnd = radopenExt("popCredentialsDialog.aspx?op=1", null);
            oWnd.SetSize(430, 230);
            oWnd.Center();
            oWnd.add_close(CredentialsClosed);
        }

        function CredentialsClosed(Wnd, args) {
            var arg = args.get_argument();
            if (arg) {
                if (!arg.canceled) {
					setTimeout(function () {
                        var currentPath = encodeURI($get("<%=txtShared.ClientID%>").value);
                        var oWnd = radopenExt('popFoldersTree.aspx?Type=<%=BrowseTreeType.Network%>&BrowseOrigin=<%=BrowseOrigin.Location%>', null);
                        oWnd.SetSize(450, 460);
                        oWnd.Center();
                        oWnd.add_close(OpenSharedSourceDialogClosed);
                    }, 0);
                }
            }
        }

        function OpenSharedOpenSourceDialog() {
            var oWnd = radopenExt("popCredentialsDialog.aspx?op=1", null);
            oWnd.SetSize(430, 230);
            oWnd.Center();
            oWnd.add_close(OpenSourceCredentialsClosed);
        }

        function OpenSourceCredentialsClosed(Wnd, args) {
            var arg = args.get_argument();
            if (arg) {
                if (!arg.canceled) {
                    setTimeout(function () {
                        var currentPath = encodeURI($get("<%=txtOSAShared.ClientID%>").value);
                        var oWnd = radopenExt('popFoldersTree.aspx?Type=<%=BrowseTreeType.Network%>&BrowseOrigin=<%=BrowseOrigin.OSA%>', null);
                        oWnd.SetSize(450, 470);
                        oWnd.Center();
                        oWnd.add_close(OpenSharedOpenSourceDialogClosed);
                    }, 0);
                }
            }
        }

        function OpenSharedSourceDialogClosed(Wnd, args) {
            var arg = args.get_argument();
            if (arg) {
				if (!arg.canceled) {
                    $get("<%=txtShared.ClientID%>").value = arg.pathList;
                }
            }
        }

        function OpenSharedOpenSourceDialogClosed(Wnd, args) {
            var arg = args.get_argument();
            if (arg) {
                if (!arg.canceled) {
                    $get("<%=txtOSAShared.ClientID%>").value = arg.pathList;
                }
            }
        }

        function RunLocalProject(i_IsIncremental) {
            var oWnd = radopenExt("popLocalSource.aspx", null);
            oWnd.SetSize(430, 180);
            oWnd.Center();
            oWnd.add_close(RunLocalWinClosed);
            incremental = i_IsIncremental;
        }

        function OpenLocalDialog() {
            var oWnd = radopenExt("popLocalSource.aspx", null);
            oWnd.SetSize(430, 190);
            oWnd.Center();
            oWnd.add_close(LocalDialogClosed);
        }

        function LocalDialogClosed(oWnd, args) {
            var arg = args.get_argument();
            if (arg) {
                if (!arg.canceled) {
                    $get("<%=txtLocal.ClientID%>").value = arg.filename;
                }
            }
        }

        function RunLocalWinClosed(oWnd, args) {
            var arg = args.get_argument();
            if (arg) {
                if (!arg.canceled) {
                    $get('<%=hdnIsIncremental.ClientID%>').value = incremental;
                    $telerik.$("#<%=btnRunLocal.ClientID%>")[0].click();
                }
            }
        }

        function ConfirmWindow(i_Msg, i_Event) {
            var e = $telerik.$.event.fix(i_Event || window.event);
            openConfirm(i_Msg, i_Event, function () { eval($telerik.$(e.currentTarget ? e.currentTarget : e.srcElement.parentNode).attr('href')); });
        }

        function ProjectRowSelected(sender, eventArgs) {
            
                var selectedScan = eventArgs.getDataKeyValue("ProjectID");
                $get("<%=hdnSelectedProject.ClientID%>").value = selectedScan;
                $telerik.$("#<%=btnProjectDetail.ClientID%>").trigger('click');
            
        }

        var previousRow;//stores the row in editing
        var isCurrentlySelecting = false;

        // If the user switches project while on editing mode, a message is prompted to warn that changes are about to be discarded
        function OnRowSelecting(sender, eventArgs) {
          
            if (isEditingMode) {
             
              if (isCurrentlySelecting) return;
              var dataItem = eventArgs.get_gridDataItem();//get clicked row
              eventArgs.set_cancel(true);

              openConfirm(ConfirmLeavingPageLossOfChanges,
                  null,
                  // if the user clicked "yes" it discards changes and switches project :
                  function () {
                      isCurrentlySelecting = true;
                      dataItem.set_selected(true);
                      isCurrentlySelecting = false;
                      cancelEdit(sender, eventArgs);
                  },
                  false,
                  // if the user clicks "no" it stays on the same project
                  function () {
                      
                      isEditingMode = false;
                      if (!Page.isValid()) {// if the form has errors, the page does not postback
                          previousRow.set_selected(true);
                      }
                      isEditingMode = true;
                  });

          } 
        }
        function RowClick(sender, eventArgs) {
            // store previously selected row
            previousRow = getActiveRow();
         
        }

        var toolbarBtn = null;
        var DELETE_PROJECTS_CONFIRMATION = '<%=this.GetTermFromResourceJsEncoded("DELETE_PROJECTS_CONFIRMATION")%>';
        var DELETE_PROJECTS_WITH_OSA_CONFIRMATION = '<%=this.GetTermFromResourceJsEncoded("DELETE_PROJECTS_WITH_OSA_CONFIRMATION")%>';
        var SELECT_PROJECTS_2_DELETE = '<%=this.GetTermFromResourceJsEncoded("SELECT_PROJECTS_2_DELETE")%>';

        function onClientButtonClicking(sender, args) {
            toolbarBtn = args.get_item();
            if (args.get_item().get_value() == '<%=k_NewProjectValue%>') {
                window.location = 'NewProject.aspx';
                args.set_cancel(true);
            } else if (args.get_item().get_value() == '<%=k_Back2ProjectStateValue%>') {
                window.location = 'portal#/projectState/' + <%=m_SelectedProjectID%> + '/Summary';
                args.set_cancel(true);

            } else if (args.get_item().get_value() == '<%=k_DeleteProjectsValue%>') {
                args.set_cancel(true);
                deleteProjects(false);
            }
        }

        function selectedProjectsContainOsaScans() {
            var items = $find('<%=ProjectsGrid.ClientID%>').get_seletedCheckboxItems();
            if (items != null) {
                var masterTable = $find('<%=ProjectsGrid.ClientID%>').get_masterTableView();
                for (var i = 0; i < items.length; i++) {

                    var cell = masterTable.getCellByColumnUniqueName(items[i], "TotalOsaScans");
                    var hasOsaScans = ($telerik.$(cell).text().trim() > 0);

                    if (hasOsaScans) {
                        return true;
                    }
                }
            }
            return false;
        }

        function getDeletionMessageTemplate() {
            var template = DELETE_PROJECTS_CONFIRMATION;
            if (selectedProjectsContainOsaScans()) {
                template = DELETE_PROJECTS_WITH_OSA_CONFIRMATION;
            }

            return template;
        }

        function deleteProjects(isConfirmed, flags) {
            var projectIDs = new Array();
            var items = $find('<%=ProjectsGrid.ClientID%>').get_seletedCheckboxItems();

            if (items != null) {
                for (var i = 0; i < items.length; i++) {
                    var id = items[i].getDataKeyValue("ProjectID");
                    projectIDs.push(id);
                }
            }

            if (projectIDs.length == 0) {

                openInfo(SELECT_PROJECTS_2_DELETE);
                return;
            } else if (!isConfirmed) {

                var message = String.format(getDeletionMessageTemplate(), projectIDs.length);
                openConfirm(message, null, function () { deleteProjects(true, flags); });
                return;
            }

            flags = flags || '<%=CxWebClientApp.CxWebServices.DeleteFlags.None %>';

            $telerik.$.ajax({
                type: 'POST',
                async: false,
                url: 'Projects.aspx/DeleteProjects',
                data: '{\'projectIdsToDelete\':' + JSON.stringify(projectIDs) +
                    ',\'flags\':\'' + flags + '\'}',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (response) {
                    if (response.d == null) {
                        top.location.href = 'Logout.aspx';
                    } else if (response.d.IsSuccessful) {
                        deselectAll('<%=ProjectsGrid.ClientID%>');
                        $find('<%=ProjectsGrid.ClientID%>').get_masterTableView().rebind();
                    } else if (response.d.UndeletedProjects != null && response.d.UndeletedProjects.length > 0) {
                        $find('<%=ProjectsGrid.ClientID%>').get_masterTableView().rebind();
                        var title = DELETE_PROJECTS_PARTLY_SUCCESSFUL.replace('{0}', response.d.NumOfDeletedProjects).replace('{1}', response.d.NumOfDeletedProjects + response.d.UndeletedProjects.length);
                        showDeleteObjectsPopup(response.d.UndeletedProjects, response.d.NumOfDeletedProjects, title, DELETE_SCANS_DOWNLOAD_TEXT, OK, DELETE_SCANS_DOWNLOAD_FILE);
                    } else if (response.d.IsConfirmation) {
                        openConfirm(response.d.ErrorMessage, null, function () { deleteProjects(true, response.d.Flags); });
                    } else {
                        openInfo(response.d.ErrorMessage, null);
                    }
                }
            });
        }

        function deselectAll(gridId) {
            var selectAllCheckbox = $telerik.$('#' + gridId + ' ._cxGrid_SelAll input[type=checkbox]');
            if (selectAllCheckbox.is(':checked')) {
                selectAllCheckbox.removeAttr('checked');
                selectAllCheckbox.prop('checked', false);
            }
            cxGrid_SelectAll(selectAllCheckbox);
        }

        var isEditingMode = false;
        function updateClick(button, args) {
            var disabled = true;

            if (button.get_uniqueID().indexOf("btnCancel") >= 0) {
                cleanAllTextFields();
                // cancel button click
                $find("<%=btnUpdate.ClientID%>").set_text('<%=this.GetTermFromResourceJsEncoded("EDIT")%>');
                $telerik.$("#<%=btnCancel.ClientID%>").hide();
                $get("<%=hdnPreviousProjectType.ClientID%>").value = $get("<%=hdnProjectType.ClientID%>").value;
                $get("<%=hdnOsaPreviousOrigin.ClientID%>").value = $get("<%=hdnOsaOrigin.ClientID%>").value;
                choosePreviousSource();
                cleanDirtyOsaPolicies();
                osaSettingsDirty = false;
                isEditingMode = false;
            } else {
                if ($get("<%=hdnSelectedProject.ClientID%>").value > "") {
                    if (button.get_text() == '<%=this.GetTermFromResourceJsEncoded("EDIT")%>') {
                        // edit button click
                        isEditingMode = true;
                        button.set_text('<%=this.GetTermFromResourceJsEncoded("UPDATE")%>');
                        button.set_autoPostBack(false);
                        disabled = false;
                        $telerik.$("#<%=btnCancel.ClientID%>").show();
                    } else {
                        // update button click
                        if (arePoliciesDirty) {
                            updateProjectPolicies();
                        }
                        if (osaSettingsDirty) {
                            updateOsaSettings();
                        }

                        if (typeof (Page_ClientValidate) == 'function') {
                            Page_ClientValidate();
                        }
                        if (Page_IsValid) {
                            $get("<%=hdnProjectType.ClientID%>").value = getSourceLocation(GetMarkedSourceLocationRadioButton().value);
                            $get("<%=hdnOsaOrigin.ClientID%>").value = getCurrentOsaOrigin();
                            $find("<%=btnUpdate.ClientID%>").set_text('<%=this.GetTermFromResourceJsEncoded("EDIT")%>');
                            $telerik.$("#<%=btnCancel.ClientID%>").hide();
                            isEditingMode = false;
                            button.set_autoPostBack(true);
                        } else {
                            isEditingMode = true;
                            button.set_autoPostBack(false);
                        }
                        return;
                    }
                } else {
                    button.set_autoPostBack(false);
                }
            }

            var isLocal = ($get("<%=hdnProjectType.ClientID%>").value == "LOCAL");

            EnableDetailFrame(!disabled);

            if (isLocal) {

                disableSchedulingPane(isLocal);
                $find("<%=btnLocal.ClientID%>").set_enabled(false);
                $find("<%=btnPulling.ClientID%>").set_enabled(false);
                $find("<%=btnShared.ClientID%>").set_enabled(false);
                $find("<%=btnSourceCtrl.ClientID%>").set_enabled(false);

            }
        }

        function cancelEdit() {

            //cleanAllTextFields();
            //$get("<%=hdnPreviousProjectType.ClientID%>").value = $get("<%=hdnProjectType.ClientID%>").value;
            //$get("<%=hdnOsaPreviousOrigin.ClientID%>").value = $get("<%=hdnOsaOrigin.ClientID%>").value;
            //choosePreviousSource();
            //cleanDirtyOsaPolicies();
            //osaSettingsDirty = false;
            isEditingMode = false;
            $telerik.$("#<%=btnCancel.ClientID%>").click();
        }
       
        function getActiveRow() {
            var grid = $find("<%=ProjectsGrid.ClientID %>");
            var MasterTable = grid.get_masterTableView();
            var selectedRows = MasterTable.get_selectedItems();

            var row = selectedRows[0];
            if (!row) {
                var dataItems = MasterTable.get_dataItems();
                row = dataItems[0];
            }
            console.log("Active Row: " + row._itemIndex)
            return row;
        }

        function cleanAllTextFields() {
            var $form = $('#aspnetForm');

            $form.find("input[type='text'], textarea").each(
                function (index) {
                    if ($(this).val().length > 0) {
                        if (!checkXSSFieldByRegularExpressionByValue($(this).val())) {
                            $(this).val("");
                        }
                    }
                }
            )
        }

        function getSourceLocation(i_objectValue) {
            if (i_objectValue === $get("<%=rbLocal.ClientID%>").value) {
                return "LOCAL";
            }
            if (i_objectValue === $get("<%=rbPulling.ClientID%>").value) {
                return "SOURCEPULLING";
            }
            if (i_objectValue === $get("<%=rbShared.ClientID%>").value) {
                return "SHARED";
            }
            if (i_objectValue === $get("<%=rbSourceCtrl.ClientID%>").value) {
                return "SOURCECONTROL";
            }
        }

        function ShcedulingChanged(i_object) {
            if (SchedulingPaneDisabled()) {
                return;
            }
            if ((i_object.value === $get("<%=rbNone.ClientID%>").value) || (i_object.value === $get("<%=rbNow.ClientID%>").value)) {

                UncheckScheduledDays();
                disableChoosingSchedulingDaysAndTime();

                var timePicker = $find("<%=TimeInput.ClientID%>");
                timePicker.get_dateInput().set_value("12:00 AM");

            }
            else {
                enableChoosingSchedulingDaysAndTime();
            }
        }

        function SchedulingPaneDisabled() {
            if ($telerik.$("#<%=rbNone.ClientID%>").is(":enabled") || $telerik.$("#<%=rbNow.ClientID%>").is(":enabled") || $telerik.$("#<%=rbBySched.ClientID%>").is(":enabled")) {
                return false;
            }
            return true;
        }

        function enableChoosingSchedulingDaysAndTime() {
            var panelExists = ensureDetailsPanelVisible();
            if (!panelExists) return;

            $telerik.$("#<%=cbMo.ClientID%>").removeAttr("disabled");
            $telerik.$("#<%=cbFr.ClientID%>").removeAttr("disabled");
            $telerik.$("#<%=cbSa.ClientID%>").removeAttr("disabled");
            $telerik.$("#<%=cbSu.ClientID%>").removeAttr("disabled");
            $telerik.$("#<%=cbTh.ClientID%>").removeAttr("disabled");
            $telerik.$("#<%=cbTu.ClientID%>").removeAttr("disabled");
            $telerik.$("#<%=cbWe.ClientID%>").removeAttr("disabled");
            $find("<%=TimeInput.ClientID%>").set_enabled(true);

        }

        function disableChoosingSchedulingDaysAndTime() {
            var panelExists = ensureDetailsPanelVisible();
            if (!panelExists) return;

            $telerik.$("#<%=cbMo.ClientID%>").attr("disabled", "disabled");
            $telerik.$("#<%=cbFr.ClientID%>").attr("disabled", "disabled");
            $telerik.$("#<%=cbSa.ClientID%>").attr("disabled", "disabled");
            $telerik.$("#<%=cbSu.ClientID%>").attr("disabled", "disabled");
            $telerik.$("#<%=cbTh.ClientID%>").attr("disabled", "disabled");
            $telerik.$("#<%=cbTu.ClientID%>").attr("disabled", "disabled");
            $telerik.$("#<%=cbWe.ClientID%>").attr("disabled", "disabled");

            var timePicker = $find("<%=TimeInput.ClientID%>");
            timePicker.set_enabled(false);

        }

        function locationChanged(i_object) {

            var hdnPreviousProjectType = $get("<%=hdnPreviousProjectType.ClientID%>");
            var previousSourceLocation = hdnPreviousProjectType.value;
            var currentSourceLocation = getSourceLocation(i_object.value);

            if (previousSourceLocation == currentSourceLocation) {
                return;
            }

            enableSourceLocationButtonsByRadioButtons();

            var wasLocal = (previousSourceLocation == "LOCAL");

            var changedToLocal = $get("<%=rbLocal.ClientID%>").checked;

            if (!wasLocal && changedToLocal) {
                // deal with change to local
                openConfirm(ConfirmChangingSourceToLocal,
                    null,
                    // if the user clicked "yes" it changes to local :
                    function () { disableSchedulingPane(true); hdnPreviousProjectType.value = currentSourceLocation; },
                    false,
                    // if the user clicks "no" it stays as it was
                    function () { enableSchedulingPane(); choosePreviousSource(); });
            }
            else if (wasLocal && !changedToLocal) {
                // deal with change from local to other 
                openConfirm(ConfirmChangingSourceFromLocal,
                    null,
                    // if the user clicked "yes" it changes from local :
                    function () { enableSchedulingPane(); hdnPreviousProjectType.value = currentSourceLocation; },
                    false,
                    // if the user clicks "no" it stays local
                    function () { disableSchedulingPane(true); choosePreviousSource(); });
            }
            else {

                hdnPreviousProjectType.value = currentSourceLocation;
            }
        }

        function OsaLocationChanged(sender) {
            var hdnPreviousOsaOrigin = $get("<%=hdnOsaPreviousOrigin.ClientID%>");
            var previousOsaOrigin = hdnPreviousOsaOrigin.value;
            var currentOsaOrigin = getCurrentOsaOrigin(sender.value);

            if (previousOsaOrigin != currentOsaOrigin) {
                setOSASharedButtonEnabled();

                return openConfirm(ConfirmChangingSourceLocationOSA,
                    null,
                    // The user clicked "yes"
                    function () { hdnPreviousOsaOrigin.value = currentOsaOrigin },
                    false,
                    // The user clicked "no" 
                    function () { chooseOsaOrigin(previousOsaOrigin); });
            }

        }

        function chooseOsaOrigin(previousOsaOrigin) {
            switch (previousOsaOrigin) {
                case 'LOCALPATH':
                    $get("<%=rbOsaOriginLocal.ClientID%>").checked = true;
                    break;
                case 'SHAREDPATH':
                    $get("<%=rbOsaOriginShared.ClientID%>").checked = true;
                    break;
            }

            setOSASharedButtonEnabled();
        }

        function getCurrentOsaOrigin(senderName) {
            if (senderName === $get("<%=rbOsaOriginLocal.ClientID%>").value) {
                return "LOCALPATH";
            }
            else {
                return "SHAREDPATH";
            }
        }

        function enableSourceLocationButtonsByRadioButtons() {
            var panelExists = ensureDetailsPanelVisible();
            if (!panelExists) return;

            $find("<%=btnLocal.ClientID%>").set_enabled(false);
            $find("<%=btnPulling.ClientID%>").set_enabled($get("<%=rbPulling.ClientID%>").checked);
            $find("<%=btnShared.ClientID%>").set_enabled($get("<%=rbShared.ClientID%>").checked);
            $find("<%=btnSourceCtrl.ClientID%>").set_enabled($get("<%=rbSourceCtrl.ClientID%>").checked);
        }

        function setOSASharedButtonEnabled() {
            $find("<%=btnOSAShared.ClientID%>").set_enabled($get("<%=rbOsaOriginShared.ClientID%>").checked);
        }

        function choosePreviousSource() {

            var hdnPreviousProjectType = $get("<%=hdnPreviousProjectType.ClientID%>");

            switch (hdnPreviousProjectType.value) {

                case 'LOCAL':
                    $get("<%=rbLocal.ClientID%>").checked = true;
                    break;
                case 'SOURCEPULLING':
                    $get("<%=rbPulling.ClientID%>").checked = true;
                    break;
                case 'SHARED':
                    $get("<%=rbShared.ClientID%>").checked = true;
                    break;
                case 'SOURCECONTROL':
                    $get("<%=rbSourceCtrl.ClientID%>").checked = true;
                    break;

            }

            enableSourceLocationButtonsByRadioButtons();
        }

        function disableSchedulingPane(i_Local) {
            var panelExists = ensureDetailsPanelVisible();
            if (!panelExists) return;

            $telerik.$("#<%=rbNone.ClientID%>").attr("disabled", "disabled");
            $telerik.$("#<%=rbNow.ClientID%>").attr("disabled", "disabled");
            $telerik.$("#<%=rbBySched.ClientID%>").attr("disabled", "disabled");
            disableChoosingSchedulingDaysAndTime();

            if (i_Local) {
                $get('<%=rbBySched.ClientID%>').checked = false;
                $get('<%=rbNow.ClientID%>').checked = false;
                $get('<%=rbNone.ClientID%>').checked = true;

                UncheckScheduledDays();

                var timePicker = $find("<%=TimeInput.ClientID%>");
                timePicker.get_dateInput().set_value("12:00 AM");

            }
        }

        function UncheckScheduledDays() {
            $get('<%=cbMo.ClientID%>').checked = false;
            $get('<%=cbTu.ClientID%>').checked = false;
            $get('<%=cbWe.ClientID%>').checked = false;
            $get('<%=cbTh.ClientID%>').checked = false;
            $get('<%=cbFr.ClientID%>').checked = false;
            $get('<%=cbSa.ClientID%>').checked = false;
            $get('<%=cbSu.ClientID%>').checked = false;
        }

        function enableSchedulingPane() {
            var panelExists = ensureDetailsPanelVisible();
            if (!panelExists) return;

            $telerik.$("#<%=rbNone.ClientID%>").removeAttr("disabled");
            $telerik.$("#<%=rbNow.ClientID%>").removeAttr("disabled");
            $telerik.$("#<%=rbBySched.ClientID%>").removeAttr("disabled");
            enableChoosingSchedulingDaysAndTime();

            // if the marked scheduling is none or now don't allow choosing days and time
            ShcedulingChanged(GetMarkedSchedulingRadioButton());
        }

        function GetMarkedSchedulingRadioButton() {
            var bySchedRadioButton = $get('<%=rbBySched.ClientID%>');
                var nowRadioButton = $get('<%=rbNow.ClientID%>');
                var noneRadioButton = $get('<%=rbNone.ClientID%>');

            if (bySchedRadioButton.checked) {
                return bySchedRadioButton;
            }

            if (nowRadioButton.checked) {
                return nowRadioButton;
            }

            return noneRadioButton;
        }

        function GetMarkedSourceLocationRadioButton() {
            var localRadioButton = $get('<%=rbLocal.ClientID%>');
                var sharedRadioButton = $get('<%=rbShared.ClientID%>');
                var sourceControlRadioButton = $get('<%=rbSourceCtrl.ClientID%>');
                var sourcePullingRadioButton = $get('<%=rbPulling.ClientID%>');

            if (sharedRadioButton.checked) {
                return sharedRadioButton;
            }

            if (sourceControlRadioButton.checked) {
                return sourceControlRadioButton;
            }

            if (sourcePullingRadioButton.checked) {
                return sourcePullingRadioButton;
            }

            return localRadioButton;
        }

        function EnableDetailFrame(i_Enable) {
            var panelExists = ensureDetailsPanelVisible();
            if (!panelExists) return;

            if (!i_Enable) {
                $telerik.$("#<%=rbLocal.ClientID%>").attr("disabled", "disabled");
                $telerik.$("#<%=rbSourceCtrl.ClientID%>").attr("disabled", "disabled");
                $telerik.$("#<%=rbShared.ClientID%>").attr("disabled", "disabled");
                $telerik.$("#<%=rbPulling.ClientID%>").attr("disabled", "disabled");

                $telerik.$("#<%=rbOsaOriginLocal.ClientID%>").attr("disabled", "disabled");
                $telerik.$("#<%=rbOsaOriginShared.ClientID%>").attr("disabled", "disabled");
                $telerik.$("#<%=enableOsaResolveDependencies.ClientID%>").attr("disabled", "disabled");

                disableSchedulingPane(false);

                $telerik.$("#<%=txtOSAShared.ClientID%>").attr("disabled", "disabled");

                $telerik.$("#<%=txtShared.ClientID%>").attr("disabled", "disabled");
                $telerik.$("#<%=txtLocal.ClientID%>").attr("disabled", "disabled");
                $telerik.$("#<%=txtSourceCtrl.ClientID%>").attr("disabled", "disabled");
                $telerik.$("#<%=txtSCUrl.ClientID%>").attr("disabled", "disabled");
                $telerik.$("#<%=txtPulling.ClientID%>").attr("disabled", "disabled");

                $find("<%=btnLocal.ClientID%>").set_enabled(false);
                $find("<%=btnPulling.ClientID%>").set_enabled(false);
                $find("<%=btnShared.ClientID%>").set_enabled(false);
                $find("<%=btnOSAShared.ClientID%>").set_enabled(false);
                $find("<%=btnSourceCtrl.ClientID%>").set_enabled(false);

                $get("imgBeforeScan").src = "Images/Icons/AddRecipientIcon.png";
                $get("imgAferScan").src = "Images/Icons/AddRecipientIcon.png";
                $get("imgFailedScan").src = "Images/Icons/AddRecipientIcon.png";

                $telerik.$("#imgBeforeScan").unbind("click");
                $telerik.$("#imgAferScan").unbind("click");
                $telerik.$("#imgFailedScan").unbind("click");
                var combo = $find("<%= PostScanList.ClientID %>");
                combo.disable();

                $find("<%=cmbPreset.ClientID%>").disable();
                $find("<%=cmbConfig.ClientID%>").disable();
                $find("<%=cmbGroup.ClientID%>").disable();
                $find("<%=cmbProjectPolicies.ClientID%>").disable();
                try { $find("<%=cmbIssueTracking.ClientID%>").disable(); } catch (e) { }
                try { $find("<%=btnITSopen.ClientID%>").set_enabled(false); } catch (e) { }

                $(".customFieldValue").prop('disabled', true);
                $('#<%=inputScansToKeep.ClientID%>').prop('disabled', true);

            } else {
                $telerik.$("#<%=rbLocal.ClientID%>").removeAttr("disabled");
                $telerik.$("#<%=rbSourceCtrl.ClientID%>").removeAttr("disabled");
                $telerik.$("#<%=rbShared.ClientID%>").removeAttr("disabled");
                $telerik.$("#<%=rbPulling.ClientID%>").removeAttr("disabled");

                $telerik.$("#<%=rbOsaOriginLocal.ClientID%>").removeAttr("disabled");
                $telerik.$("#<%=rbOsaOriginShared.ClientID%>").removeAttr("disabled");
                $telerik.$("#<%=enableOsaResolveDependencies.ClientID%>").removeAttr("disabled", "disabled");

                enableSchedulingPane();

                setOSASharedButtonEnabled();

                $telerik.$("#<%=txtOSAShared.ClientID%>").removeAttr("disabled");

				$telerik.$("#<%=txtLocal.ClientID%>").removeAttr("disabled");
                $telerik.$("#<%=txtShared.ClientID%>").removeAttr("disabled");
                $telerik.$("#<%=txtSourceCtrl.ClientID%>").removeAttr("disabled");
                $telerik.$("#<%=txtSCUrl.ClientID%>").removeAttr("disabled");
                $telerik.$("#<%=txtPulling.ClientID%>").removeAttr("disabled");

                enableSourceLocationButtonsByRadioButtons();
                $get("imgBeforeScan").src = "Images/Icons/AddRecipientIcon.png";

                $telerik.$("#imgBeforeScan").click(function () { OpenEmailDialog(2) });
                $telerik.$("#imgAferScan").click(function () { OpenEmailDialog(1) });
                $telerik.$("#imgFailedScan").click(function () { OpenEmailDialog(3) });

                $get("imgAferScan").src = "Images/Icons/AddRecipientIcon.png";
                $get("imgFailedScan").src = "Images/Icons/AddRecipientIcon.png";
                var combo = $find("<%= PostScanList.ClientID %>");
                combo.enable();

                $find("<%=cmbPreset.ClientID%>").enable();
                $find("<%=cmbConfig.ClientID%>").enable();
                $find("<%=cmbGroup.ClientID%>").enable();
                $find("<%=cmbProjectPolicies.ClientID%>").enable();
                setIssueTrackingAllowed();
                $(".customFieldValue").prop('disabled', false);
                $('#<%=inputScansToKeep.ClientID%>').prop('disabled', false);
            }

            $get("<%=txtPrjName.ClientID%>").disabled = !i_Enable;
            $get("<%=txtAfterScanSucceds.ClientID%>").disabled = !i_Enable;
            $get("<%=txtBeforeStartScan.ClientID%>").disabled = !i_Enable;
            $get("<%=txtScanFailed.ClientID%>").disabled = !i_Enable;

            $find("<%=SourceFilterPatternControl.ClientID%>").set_enabled(i_Enable);
        }

        function setIssueTrackingAllowed() {
            var isIssueTrackingAllowed = <%= m_IsLicenseSDLCEdition.ToString().ToLower() %>;
                try {
                    if (isIssueTrackingAllowed) {
                        $find('<%=cmbIssueTracking.ClientID%>').enable();
                    } else {
                        $find('<%=cmbIssueTracking.ClientID%>').disable();
                    }
                } catch (e) { }
                try { $find('<%=btnITSopen.ClientID%>').set_enabled(isIssueTrackingAllowed); } catch (e) { }
        }

		function sharedValidation(sender, args) {
			var selectedTabName = $find("<%=ProjectTabStrip.ClientID%>").get_selectedTab()._properties._data.pageViewID;
			if (selectedTabName.indexOf("Step2PageView")<0) return true;
            args.IsValid = !($get("<%=rbShared.ClientID%>").checked && $get("<%=txtShared.ClientID%>").value == "");
        }

        function osaSharedValidation(sender, args) {
            args.IsValid = !($get("<%=rbOsaOriginShared.ClientID%>").checked && $get("<%=txtOSAShared.ClientID%>").value == "");
        }

        function sourceCtrlValidation(sender, args) {
            args.IsValid = !($get("<%=rbSourceCtrl.ClientID%>").checked && $get("<%=txtSourceCtrl.ClientID%>").value == "");
        }

        function pullingValidation(sender, args) {
            args.IsValid = !($get("<%=rbPulling.ClientID%>").checked && $get("<%=txtPulling.ClientID%>").value == "");
        }

        function ValidateEmails(source, arguments) {

            arguments.IsValid = CheckEmailsByValue(arguments.Value);
            source.innerText = EmailsErrorMessage;
        }

        function CheckEmailsByValue(value) {
            var flag = true;
            EmailsErrorMessage = "";

            if (value == "") {
                return true;
            } else {
                emailsArr = value.split(";");
                if (emailsArr.length > EmailMaxCount) {
                    EmailsErrorMessage = EmailMaxCountError;
                    return false;
                }
                for (var i = 0; i < emailsArr.length; i++) {
                    if (emailsArr[i].trim() != "") {
                        if (!CheckEmail(emailsArr[i].trim())) {
                            flag = false;
                            break;
                        }
                    }
                }
            }

            if (flag)
                if (value.length > EmailsMaxLength) {
                    EmailsErrorMessage = EmailsMaxLengthError;
                    flag = false;
                }
            return flag;
        }

        function fixDisableDisappear(e) {
            e.updateCssClass();
        }

        function openITS(sender, args) {
            var id = $find('<%=cmbIssueTracking.ClientID%>').get_selectedItem().get_value();
                if (id > '') {
                    var oWnd = radopenExt('popIssueTrackingSettings.aspx?pid=' + $get('<%=hdnSelectedProject.ClientID%>').value + '&itsid=' + id, null);
                oWnd.SetSize(750, 330);
                oWnd.add_close(function () { });
            }
        }

        function publishScanResult(sender) {
            if (isCurrentProjectUnpublished) {
                startPublishScanResult(sender);
            }
            else {
                var message = PUBLISH_SCAN_RESULTS_CONFIRMATION;
                openConfirm(message, null, function () { startPublishScanResult(sender); });
            }
        }

        function startPublishScanResult(sender) {
            var currentProjectId = $get("<%=hdnSelectedProject.ClientID%>").value;
            var projectSyncStatusLabel = $("#<%= lblPrjPolicySyncStatus.ClientID %>");
            var lastSyncProjectLabel = $("#<%= lblPrjPolicyLastSync.ClientID %>");
            changeParamsStatusToInProgress(sender, projectSyncStatusLabel,lastSyncProjectLabel);
            publishScanResultSave(currentProjectId,sender,projectSyncStatusLabel);
        }

        var isCurrentProjectUnpublished = false;
        function getStatusScanResult() {
            var currentProjectId = $get("<%=hdnSelectedProject.ClientID%>").value;
            var btnSync = document.getElementById('<%= policySyncId.ClientID %>');
            var projectSyncStatusLabel = $("#<%= lblPrjPolicySyncStatus.ClientID %>");
            var lastSyncProjectLabel = $("#<%= lblPrjPolicyLastSync.ClientID %>");
            publishScanResultGet(currentProjectId,btnSync,projectSyncStatusLabel,lastSyncProjectLabel);
        }     

    </script>
</asp:Content>
<asp:Content ID="cnt2" ContentPlaceHolderID="cpmain" runat="Server">
    <script type="text/javascript">
        function onRequestStart(sender, args) {
            requestStart(sender, args);

            if (args.get_eventTarget().indexOf("_GridToolbar") >= 0) {
                if (toolbarBtn.get_value() != "REFRESH") {
                    args.set_enableAjax(false);
                }
            }
        }
    </script>

    <telerik:RadAjaxLoadingPanel ID="pnlLoading" runat="server" Skin="Silk">
    </telerik:RadAjaxLoadingPanel>
    <telerik:RadAjaxManager ID="ajaxMngr" runat="server" ClientEvents-OnRequestStart="onRequestStart"
        DefaultLoadingPanelID="pnlLoading">
        <AjaxSettings>
            <telerik:AjaxSetting AjaxControlID="ProjectsGrid">
                <UpdatedControls>
                    <telerik:AjaxUpdatedControl ControlID="ProjectsGrid" />
                    <telerik:AjaxUpdatedControl ControlID="pnlWrapper" />
                </UpdatedControls>
            </telerik:AjaxSetting>
            <telerik:AjaxSetting AjaxControlID="btnProjectDetail">
                <UpdatedControls>
                    <telerik:AjaxUpdatedControl ControlID="pnlWrapper" />
                </UpdatedControls>
            </telerik:AjaxSetting>
            <telerik:AjaxSetting AjaxControlID="btnUpdate">
                <UpdatedControls>
                    <telerik:AjaxUpdatedControl ControlID="pnlDetails" />
                    <telerik:AjaxUpdatedControl ControlID="ProjectsGrid" />
                </UpdatedControls>
            </telerik:AjaxSetting>
            <telerik:AjaxSetting AjaxControlID="btnRunLocal">
                <UpdatedControls>
                    <telerik:AjaxUpdatedControl ControlID="pnlWrapper" />
                    <telerik:AjaxUpdatedControl ControlID="ProjectsGrid" />
                </UpdatedControls>
            </telerik:AjaxSetting>
        </AjaxSettings>
    </telerik:RadAjaxManager>
    <div class="box">

        <div class="box-content" style="min-height: 600px; padding-right: 2px;">
            <CX:CxGrid ID="ProjectsGrid" runat="server" ShowGroupPanel="true" AllowSorting="True"
                ExportHiddenColumnsList="GOSCANS,Action"
                AllowPaging="true" AllowCustomPaging="true" PagerStyle-AlwaysVisible="true" VirtualItemCount="1000" 
                AllowFilteringByColumn="True" MultiSelectionCheckboxes="true"
                EnableViewState="true" EnableLinqExpressions="false">
                <MasterTableView AutoGenerateColumns="false" DataKeyNames="ProjectID" ClientDataKeyNames="ProjectID"
                    GroupLoadMode="Client" ShowHeadersWhenNoRecords="true" EnableNoRecordsTemplate="true"
                    AllowAutomaticInserts="false">
                    <Columns>
                        <%-- Hidden Columns Start --%>

                        <%-- Project ID --%>
                        <telerik:GridBoundColumn DataField="ProjectID" Display="false" UniqueName="ProjectID" SortExpression="ProjectID"
                            AllowFiltering="true" AutoPostBackOnFilter="true" CurrentFilterFunction="Contains">
                        </telerik:GridBoundColumn>
                         <%-- Hidden Columns End --%>

                        <telerik:GridBoundColumn DataField="TotalOsaScans" Display="false" UniqueName="TotalOsaScans">
                        </telerik:GridBoundColumn>
                          <telerik:GridTemplateColumn  DataField="ProjectName" UniqueName="ProjectName" SortExpression="ProjectName"  >
                                 <ItemTemplate><%#CxPortalHttpSanitizer.Instance.SanitizeResponseSplitting(DataBinder.Eval(Container.DataItem, "ProjectName").ToString())%></ItemTemplate>
                               </telerik:GridTemplateColumn>
                        <telerik:GridBoundColumn DataField="Owner" UniqueName="Owner" SortExpression="Owner">
                        </telerik:GridBoundColumn>
                        <telerik:GridTemplateColumn DataField="Group" UniqueName="Group" SortExpression="Group">
                            <ItemTemplate>
                                <code ng-non-bindable>
                                    <%#this.EncodeCurrentField(DataBinder.Eval(Container.DataItem, "Group").ToString())%>
                                </code>
                            </ItemTemplate>
                        </telerik:GridTemplateColumn>
                        <telerik:GridTemplateColumn DataField="Preset" UniqueName="Preset" SortExpression="Preset">
                            <ItemTemplate>
                                <code ng-non-bindable>
                                    <%#this.EncodeCurrentField(DataBinder.Eval(Container.DataItem, "Preset").ToString())%>
                                </code>
                            </ItemTemplate>
                        </telerik:GridTemplateColumn>
                        <telerik:GridNumericColumn DataField="TotalScans" UniqueName="TotalScans" SortExpression="TotalScans" DataType="System.Int32"
                            HeaderStyle-Width="80px">
                        </telerik:GridNumericColumn>
                        <telerik:GridDateTimeColumn DataField="LastScanned" DataType="System.DateTime" UniqueName="LastScanned"
                            HeaderStyle-Width="120px" SortExpression="LastScanned">
                        </telerik:GridDateTimeColumn>
                        <telerik:GridTemplateColumn HeaderStyle-Width="120px" HeaderStyle-HorizontalAlign="Center"
                            ItemStyle-HorizontalAlign="Center" ItemStyle-VerticalAlign="Middle" Groupable="false"
                            AllowFiltering="false" UniqueName="GOSCANS">
                            <ItemTemplate>
                                <a href="#" runat="server" id="lnkScans">
                                    <img alt="" runat="Server" id="imgScans" width="16" height="16" title="" src="Images/Ico/text_list_bullets.png" />
                                </a>
                            </ItemTemplate>
                        </telerik:GridTemplateColumn>
                        <telerik:GridTemplateColumn HeaderStyle-Width="120px" Groupable="false" AllowFiltering="false"
                            UniqueName="ACTION" ItemStyle-CssClass="actionbuttons" HeaderStyle-CssClass="actionbuttons">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnRun" CommandName="RunProject" runat="server" CssClass='<%# Convert.ToBoolean(Eval("CanScan")) == true ? "availableAction" : "unavailableAction" %>'>
                                    <img alt="" id="imgRun" title="" width="16" height="16" runat="server" src="Images/icons/play.png" />
                                </asp:LinkButton>
                                <asp:LinkButton ID="lnkValFix" CommandName="IncrementalScan" runat="server" CssClass='<%# Convert.ToBoolean(Eval("CanScan")) == true ? "availableAction" : "unavailableAction" %>'>
                                    <img alt="fix" id="imgIncremScan" style="margin-left: 5px;" width="16" height="16" runat="server" src="Images/Icons/playplus.png" />&nbsp;
                                </asp:LinkButton>
                                <a href="#" runat="server" id="lnkBranch" style="padding: 0px; margin: 0px;">
                                    <img alt="" id="imgBranch" style="margin-left: 2px;" title="" width="16" height="16" runat="server" src="Images/Icons/arrow-branch-icon.png" />
                                </a>
                                <a href="#" runat="server" id="lnkDuplicate" style="padding: 0px; margin: 0px; margin-left: 6px;">
                                    <img alt="" id="imgDuplicate" title="" width="16" height="16" runat="server" src="Images/ico/page_copy.png" />
                                </a>
                            </ItemTemplate>
                        </telerik:GridTemplateColumn>
                    </Columns>
                    <SortExpressions>
                        <telerik:GridSortExpression FieldName="LastScanned" SortOrder="Descending" />
                    </SortExpressions>
                </MasterTableView>
                <ClientSettings ReorderColumnsOnClient="True" AllowDragToGroup="True" AllowColumnsReorder="True"
                    AllowGroupExpandCollapse="true">
                    <Resizing AllowRowResize="false" AllowColumnResize="True" EnableRealTimeResize="True"
                        ResizeGridOnColumnResize="False"></Resizing>
                    <Selecting AllowRowSelect="true" />
                    <ClientEvents OnRowSelected="ProjectRowSelected" OnRowSelecting="OnRowSelecting" OnRowClick="RowClick" ></ClientEvents>
                    <ClientEvents OnMasterTableViewCreated="MTVCreated" />                    
                    <ClientEvents OnCommand="GridCommand" />
                </ClientSettings>
                <GroupingSettings ShowUnGroupButton="true" />
                <PagerStyle AlwaysVisible="True" Mode="NextPrevAndNumeric" />
                <ExportSettings Pdf-PaperSize="A4" Pdf-PageTitle="Projects" FileName="Projects">
                    <Pdf PageHeight="210mm" PageWidth="297mm" PageTitle="Projects" />
                    <Excel Format="Html" />
                </ExportSettings>
            </CX:CxGrid>
            <br />
            <asp:Panel ID="pnlWrapper" runat="server">
                <div style="display: none">
                    <asp:HiddenField ID="RepositoryHiddenField" runat="server" />
                    <asp:HiddenField ID="PortHiddenField" runat="server" />
                    <asp:HiddenField ID="ServerNameHiddenField" runat="server" />
                    <asp:HiddenField ID="hdnSelectedProject" runat="server" />
                    <asp:HiddenField ID="hdnIsIncremental" EnableViewState="false" runat="server" />
                    <asp:HiddenField ID="hdnProjectType" runat="server" />
                    <asp:HiddenField ID="hdnPreviousProjectType" runat="server" />
                    <asp:HiddenField ID="hdnOsaOrigin" runat="server" />
                    <asp:HiddenField ID="hdnOsaPreviousOrigin" runat="server" />
                    <asp:Button ID="btnProjectDetail" runat="server" EnableViewState="false" OnClick="btnProjectDetail_Click" />
                    <asp:Button ID="btnRunLocal" runat="server" OnClick="btnRunLocal_Click" Text="Button" />
                </div>
                <asp:Panel ID="pnlDetails" runat="server" Visible="false">
                    <asp:HiddenField ID="HiddenGitHubCollaboratorAuthenticationMethod" runat="server" />                             
                    <asp:HiddenField ID="HiddenGitHubCollaboratorUserName" runat="server" />                             
                    <asp:HiddenField ID="HiddenGitHubOwnerAuthenticationMethod" runat="server" />                             
                    <asp:HiddenField ID="HiddenGitHubOwnerUserName" runat="server" />                             
                    <asp:HiddenField ID="HiddenGitHubThreshold" runat="server" />
                    <telerik:RadTabStrip ID="ProjectTabStrip" runat="server" MultiPageID="mpRoject" SelectedIndex="0"
                        Skin="Silk">
                        <Tabs>
                            <telerik:RadTab Text="Monitoring" PageViewID="ProjectMonitoringPageView">
                            </telerik:RadTab>
                            <telerik:RadTab Text="General" PageViewID="Step1PageView">
                            </telerik:RadTab>
                            <telerik:RadTab Text="Location" PageViewID="Step2PageView">
                            </telerik:RadTab>
                            <telerik:RadTab Text="Scheduling" PageViewID="Step3PageView">
                            </telerik:RadTab>
                            <telerik:RadTab Text="Advanced" PageViewID="Step4PageView">
                            </telerik:RadTab>
                            <telerik:RadTab Text="CustomFields" PageViewID="Step5PageView">
                            </telerik:RadTab>
                            <telerik:RadTab Text="DataRetention" PageViewID="Step6PageView">
                            </telerik:RadTab>
                            <telerik:RadTab Text="OSA" ClientIDMode="Static" ID="osaTab" PageViewID="Step7PageView" >
                            </telerik:RadTab>
                        </Tabs>
                    </telerik:RadTabStrip>
                    <telerik:RadMultiPage ID="mpRoject" runat="server" SelectedIndex="0" class="white">
                        <telerik:RadPageView ID="ProjectMonitoringPageView" runat="server">
                            <div class="DetailsContentContainer" style="min-height: 305px; border-bottom: none;">
                                <div style="padding: 8px">
                                    <table cellpadding="0" cellspacing="5" style="min-width: 500px;">
                                        <tr>
                                            <td style="vertical-align: middle; text-align: center">
                                                <fieldset dir="ltr" style="min-height: 200px !important; min-width: 250px !important">
                                                    <legend id="prjVulnerab" enableviewstate="false" runat="server"></legend>
                                                    <telerik:RadChart ID="ProjectVulnerabilitiesChart" EnableViewState="false" runat="server"
                                                        Width="350px" Height="200px" Skin="Web20" AutoLayout="true" AutoTextWrap="true"
                                                        IntelligentLabelsEnabled="false">
                                                        <Legend>
                                                            <Appearance Dimensions-AutoSize="False" Dimensions-Height="25px" Dimensions-Margins="1px, 1px, 1px, 1px"
                                                                Dimensions-Paddings="2px, 2px, 2px, 2px" Dimensions-Width="280px" Position-AlignedPosition="Top">
                                                                <ItemAppearance Visible="false">
                                                                </ItemAppearance>
                                                                <Border Color="165, 190, 223" />
                                                            </Appearance>
                                                            <Items>
                                                                <telerik:LabelItem Name="High">
                                                                    <TextBlock Text="High">
                                                                    </TextBlock>
                                                                    <Marker Visible="True">
                                                                        <Appearance>
                                                                            <FillStyle MainColor="Red" SecondColor="Red">
                                                                            </FillStyle>
                                                                        </Appearance>
                                                                    </Marker>
                                                                </telerik:LabelItem>
                                                                <telerik:LabelItem Name="Medium">
                                                                    <TextBlock Text="Medium">
                                                                    </TextBlock>
                                                                    <Marker Visible="True">
                                                                        <Appearance>
                                                                            <FillStyle MainColor="Orange" SecondColor="Orange">
                                                                            </FillStyle>
                                                                        </Appearance>
                                                                    </Marker>
                                                                </telerik:LabelItem>
                                                                <telerik:LabelItem Name="Low">
                                                                    <TextBlock Text="Low">
                                                                    </TextBlock>
                                                                    <Marker Visible="True">
                                                                        <Appearance>
                                                                            <FillStyle MainColor="Yellow" SecondColor="Yellow">
                                                                            </FillStyle>
                                                                        </Appearance>
                                                                    </Marker>
                                                                </telerik:LabelItem>
                                                                <telerik:LabelItem Name="Info">
                                                                    <TextBlock Text="Info">
                                                                    </TextBlock>
                                                                    <Marker Visible="True">
                                                                        <Appearance>
                                                                            <FillStyle MainColor="Green" SecondColor="Green">
                                                                            </FillStyle>
                                                                        </Appearance>
                                                                    </Marker>
                                                                </telerik:LabelItem>
                                                            </Items>
                                                        </Legend>
                                                        <ChartTitle>
                                                            <Appearance Visible="false">
                                                                <FillStyle MainColor="">
                                                                </FillStyle>
                                                            </Appearance>
                                                            <TextBlock>
                                                                <Appearance TextProperties-Color="0, 0, 79">
                                                                </Appearance>
                                                            </TextBlock>
                                                        </ChartTitle>
                                                        <Appearance>
                                                            <Border Visible="false" />
                                                        </Appearance>
                                                        <PlotArea>
                                                            <YAxis AxisMode="Extended">
                                                                <AxisLabel>
                                                                    <TextBlock Visible="false">
                                                                    </TextBlock>
                                                                </AxisLabel>
                                                                <Appearance MajorGridLines-Visible="true" MajorTick-Visible="true" MinorTick-Visible="true"
                                                                    MinorGridLines-Visible="false" LabelAppearance-Visible="true">
                                                                    <MajorGridLines Color="209, 221, 238" />
                                                                    <MinorGridLines Color="209, 221, 238" Visible="False" />
                                                                </Appearance>
                                                            </YAxis>
                                                            <EmptySeriesMessage Visible="True">
                                                                <Appearance Visible="True">
                                                                </Appearance>
                                                            </EmptySeriesMessage>
                                                            <XAxis>
                                                                <AxisLabel>
                                                                    <TextBlock Visible="false">
                                                                    </TextBlock>
                                                                </AxisLabel>
                                                                <Appearance LabelAppearance-Visible="true" MajorGridLines-Visible="true" MajorTick-Visible="true"
                                                                    MinorGridLines-Visible="false" MinorTick-Visible="true">
                                                                    <MajorGridLines Color="209, 221, 238" Width="0" />
                                                                </Appearance>
                                                            </XAxis>
                                                            <Appearance Dimensions-Margins="5px" Dimensions-Paddings="0px">
                                                                <FillStyle FillType="Solid" MainColor="249, 250, 251">
                                                                </FillStyle>
                                                                <Border Visible="true" />
                                                            </Appearance>
                                                        </PlotArea>
                                                    </telerik:RadChart>
                                                    <asp:Literal ID="ltNoScan1" Visible="false" EnableViewState="false" runat="server"></asp:Literal>
                                                </fieldset>
                                            </td>
                                            <td style="vertical-align: middle; text-align: center">
                                                <fieldset dir="ltr" style="min-height: 200px !important; min-width: 250px !important">
                                                    <legend id="prjRiskLegend" enableviewstate="false" runat="server">Risk Indicator</legend>
                                                    <telerik:RadChart ID="ProjectRiskIndicatorChart" EnableViewState="false" runat="server"
                                                        IntelligentLabelsEnabled="true" AutoLayout="false" Width="320px" Height="200px"
                                                        Skin="Web20">
                                                        <Series>
                                                            <telerik:ChartSeries Name="Series 1">
                                                                <Appearance>
                                                                    <FillStyle FillType="ComplexGradient">
                                                                        <FillSettings>
                                                                            <ComplexGradient>
                                                                                <telerik:GradientElement Color="213, 247, 255" />
                                                                                <telerik:GradientElement Color="193, 239, 252" Position="0.5" />
                                                                                <telerik:GradientElement Color="157, 217, 238" Position="1" />
                                                                            </ComplexGradient>
                                                                        </FillSettings>
                                                                    </FillStyle>
                                                                    <TextAppearance TextProperties-Color="103, 136, 190">
                                                                    </TextAppearance>
                                                                </Appearance>
                                                            </telerik:ChartSeries>
                                                            <telerik:ChartSeries Name="Series 2">
                                                                <Appearance>
                                                                    <FillStyle FillType="ComplexGradient">
                                                                        <FillSettings>
                                                                            <ComplexGradient>
                                                                                <telerik:GradientElement Color="218, 254, 122" />
                                                                                <telerik:GradientElement Color="198, 244, 80" Position="0.5" />
                                                                                <telerik:GradientElement Color="153, 205, 46" Position="1" />
                                                                            </ComplexGradient>
                                                                        </FillSettings>
                                                                    </FillStyle>
                                                                    <TextAppearance TextProperties-Color="103, 136, 190">
                                                                    </TextAppearance>
                                                                    <Border Color="111, 174, 12" />
                                                                </Appearance>
                                                            </telerik:ChartSeries>
                                                        </Series>
                                                        <Legend>
                                                            <Appearance>
                                                                <ItemAppearance Visible="false">
                                                                </ItemAppearance>
                                                                <Border Color="165, 190, 223" />
                                                            </Appearance>
                                                        </Legend>
                                                        <ChartTitle Visible="false">
                                                        </ChartTitle>
                                                        <Appearance>
                                                            <Border Visible="false" />
                                                        </Appearance>
                                                        <PlotArea>
                                                            <YAxis AutoScale="False" MaxValue="100" MinValue="0" Step="20">
                                                                <AxisLabel>
                                                                    <TextBlock Visible="true">
                                                                    </TextBlock>
                                                                    <Appearance Visible="true" Position-AlignedPosition="Top">
                                                                    </Appearance>
                                                                </AxisLabel>
                                                                <Appearance MajorGridLines-Visible="false" MajorTick-Visible="false" MinorTick-Visible="false"
                                                                    MinorGridLines-Visible="false" LabelAppearance-Visible="false">
                                                                    <MajorGridLines Color="209, 221, 238" Visible="False" />
                                                                    <MinorGridLines Color="209, 221, 238" Visible="False" />
                                                                    <LabelAppearance Visible="False">
                                                                    </LabelAppearance>
                                                                </Appearance>
                                                                <Items>
                                                                    <telerik:ChartAxisItem>
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="20">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="40">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="60">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="80">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="100">
                                                                    </telerik:ChartAxisItem>
                                                                </Items>
                                                            </YAxis>
                                                            <XAxis AutoScale="False" LayoutMode="Normal" MaxValue="100" MinValue="0" Step="1">
                                                                <AxisLabel>
                                                                    <TextBlock Visible="true">
                                                                    </TextBlock>
                                                                    <Appearance Visible="true" Position-AlignedPosition="Right">
                                                                    </Appearance>
                                                                </AxisLabel>
                                                                <Appearance MajorGridLines-Visible="false" MajorTick-Visible="false" MinorGridLines-Visible="false"
                                                                    LabelAppearance-Visible="false">
                                                                    <MajorGridLines Color="209, 221, 238" Visible="False" Width="0" />
                                                                    <LabelAppearance Visible="False">
                                                                    </LabelAppearance>
                                                                </Appearance>
                                                                <Items>
                                                                    <telerik:ChartAxisItem>
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="1">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="2">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="3">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="4">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="5">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="6">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="7">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="8">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="9">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="10">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="11">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="12">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="13">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="14">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="15">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="16">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="17">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="18">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="19">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="20">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="21">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="22">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="23">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="24">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="25">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="26">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="27">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="28">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="29">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="30">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="31">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="32">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="33">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="34">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="35">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="36">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="37">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="38">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="39">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="40">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="41">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="42">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="43">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="44">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="45">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="46">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="47">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="48">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="49">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="50">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="51">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="52">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="53">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="54">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="55">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="56">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="57">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="58">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="59">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="60">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="61">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="62">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="63">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="64">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="65">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="66">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="67">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="68">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="69">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="70">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="71">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="72">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="73">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="74">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="75">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="76">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="77">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="78">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="79">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="80">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="81">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="82">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="83">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="84">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="85">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="86">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="87">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="88">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="89">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="90">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="91">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="92">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="93">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="94">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="95">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="96">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="97">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="98">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="99">
                                                                    </telerik:ChartAxisItem>
                                                                    <telerik:ChartAxisItem Value="100">
                                                                    </telerik:ChartAxisItem>
                                                                </Items>
                                                            </XAxis>
                                                            <Appearance Dimensions-Margins="15px" Dimensions-Paddings="0px">
                                                                <FillStyle FillType="Image" FillSettings-BackgroundImage="Images/Common/Graph.jpg"
                                                                    FillSettings-ImageAlign="Top" FillSettings-ImageDrawMode="Stretch">
                                                                    <FillSettings BackgroundImage="Images/Common/Graph.jpg" ImageAlign="Top">
                                                                    </FillSettings>
                                                                </FillStyle>
                                                                <Border Visible="true" />
                                                            </Appearance>
                                                        </PlotArea>
                                                    </telerik:RadChart>
                                                    <asp:Literal ID="ltNoScan2" Visible="false" EnableViewState="false" runat="server"></asp:Literal>
                                                </fieldset>
                                            </td>
                                            <td class="isProjectPoliciesMngInstalled" style="vertical-align: middle; text-align: center">
                                                <fieldset dir="ltr" style="min-height: 200px !important; min-width: 250px !important">
                                                    <legend id="prjPolicySync" enableviewstate="false" runat="server">Management & Orchestration Publisher</legend>
                                                    <asp:Panel runat="server" ID="divPrjPolicySync" CssClass="policySyncPanelWithScan">
                                                        <img style="margin-top: 15px;" alt="" id="imgPrjPolicySync" width="37px" height="47px" src="Images/Icons/syncProjectPolicies.png" />
                                                        <br /><br />
                                                        <label enableviewstate="false" id="lblPrjPolicySyncStatus" class="policy-sync-status" runat="server" for="txtPrjPolicySyncStatus"></label>
                                                        <br />
                                                        <label enableviewstate="false" id="lblPrjPolicyLastSync" class="policy-sync-status" runat="server" for="txtPrjPolicyLastSync"></label>
                                                        <br /><br />
                                                        <div>
                                                            <asp:Button runat="server" ID="policySyncId" Text="Publish" CssClass="policyStaticSync" OnClientClick="return publishScanResult(this);" />       
                                                        </div>
                                                    </asp:Panel>
                                                </fieldset>
                                            </td>
                                        </tr>
                                    </table>
                                    <div style="margin: 10px auto; text-align: center;">
                                        <asp:Label ID="lblUpdateDate" runat="server"></asp:Label>
                                    </div>
                                </div>
                            </div>
                        </telerik:RadPageView>
                        <telerik:RadPageView ID="Step1PageView" runat="server">
                            <div class="DetailsContentContainer" style="min-height: 300px; border-bottom: none;">
                                <div style="padding: 20px 0px 20px 20px">
                                    <table cellpadding="2" cellspacing="5">
                                        <colgroup>
                                            <col width="100px" />
                                        </colgroup>
                                        <tr>
                                            <td>
                                                <label enableviewstate="false" id="lblProjName" runat="server" for="txtPrjName">
                                                </label>
                                            </td>
                                            <td>
                                                <asp:TextBox ID="txtPrjName" runat="server" TabIndex="1" Width="347"></asp:TextBox>
                                                <asp:RegularExpressionValidator ID="revPrjName" runat="server" ControlToValidate="txtPrjName" EnableViewState="false">
                                                </asp:RegularExpressionValidator>
                                                <asp:RequiredFieldValidator ID="rqfPrjName" runat="server" EnableViewState="false"
                                                    ControlToValidate="txtPrjName">
                                                </asp:RequiredFieldValidator>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <label enableviewstate="false" id="lblPreset" runat="server" for="cmbPreset">
                                                </label>
                                            </td>
                                            <td>
                                                <telerik:RadComboBox ng-non-bindable ID="cmbPreset" Skin="Silk" runat="server" Width="350" TabIndex="2" AutoCompleteSeparator=";"
                                                    MarkFirstMatch="True" EnableViewState="false">
                                                </telerik:RadComboBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <label enableviewstate="false" id="lblConf" runat="server" for="cmbConfig">
                                                </label>
                                            </td>
                                            <td>
                                                <telerik:RadComboBox ID="cmbConfig" runat="server" Skin="Silk" Width="350" EnableViewState="false"
                                                    TabIndex="3" AutoCompleteSeparator=";" MarkFirstMatch="True">
                                                </telerik:RadComboBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <label enableviewstate="false" id="lblGroup" runat="server" for="cmbGroup">
                                                </label>
                                            </td>
                                            <td>
                                                <telerik:RadComboBox ng-non-bindable ID="cmbGroup" runat="server" Skin="Silk" Width="350" EnableViewState="false"
                                                    TabIndex="4" AutoCompleteSeparator=";" MarkFirstMatch="True">
                                                </telerik:RadComboBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <div class="isProjectPoliciesMngInstalled">
                                                    <label enableviewstate="false" id="lblProjectPolicies" runat="server" for="cmbProjectPolicies" Style="margin-right:14px;">
                                                    </label>
                                                </div>
                                            </td>
                                            <td>
                                                <div class="isProjectPoliciesMngInstalled">
                                                    <telerik:RadComboBox ID="cmbProjectPolicies"  EnableLoadOnDemand="True" runat="server" OnClientLoad="disableRadComboBoxInputField"
                                                        Skin="Silk" Width="351px" TabIndex="4" CheckBoxes="true" EnableCheckAllItemsCheckBox="false" OnRequestStart="policiesAjaxStart"
                                                        OnClientItemChecking="setProjectPolicyChecked">
                                                    </telerik:RadComboBox>
                                                    <label runat="server" id="lblFailedToLoadPolicies" Style="display:none;margin-left:20px;color:red;"><%= GetTermFromResource("FAILED_TO_LOAD_POLICIES") %> </label>
                                                    <label runat="server" id="lblFailedToUpdatePolicies" Style="display:none;margin-left:20px;color:red;"><%= GetTermFromResource("FAILED_TO_UPDATE_POLICIES") %> </label>
                                                </div>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                        </telerik:RadPageView>
                        <telerik:RadPageView ID="Step2PageView" runat="server">
                            <div class="DetailsContentContainer" style="min-height: 300px; border-bottom: none;">
                                <div style="display: inline-block; padding: 20px;">
                                    <table cellpadding="2" cellspacing="5" border="0">
                                        <colgroup>
                                            <col width="20px" />
                                            <col width="100px" />
                                        </colgroup>
                                        <tr>
                                            <td>
                                                <asp:RadioButton ID="rbLocal" runat="server" GroupName="Step2Options" AutoPostBack="false"
                                                    EnableViewState="false" />
                                            </td>
                                            <td>
                                                <label enableviewstate="false" id="lblLocal" runat="server" for="rbLocal">
                                                </label>
                                            </td>
                                            <td>
                                                <table>
                                                    <tr>
                                                        <td>
                                                            <asp:TextBox ID="txtLocal" EnableViewState="false" runat="server" Width="350" TabIndex="1"></asp:TextBox>
                                                        </td>
                                                        <td>
                                                            <telerik:RadButton ID="btnLocal" runat="server" Width="65px" Font-Underline="false"
                                                                AutoPostBack="false" CausesValidation="false" EnableViewState="false" UseSubmitBehavior="false"
                                                                OnClientClicking="OpenLocalDialog">
                                                            </telerik:RadButton>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:RadioButton ID="rbShared" runat="server" GroupName="Step2Options" AutoPostBack="false" />
                                            </td>
                                            <td>
                                                <label enableviewstate="false" id="lblShared" runat="server" for="txtShared">
                                                </label>
                                            </td>
                                            <td>
                                                <table>
                                                    <tr>
                                                        <td>
                                                            <asp:TextBox ID="txtShared" runat="server" Width="350" EnableViewState="false" TabIndex="1">
                                                            </asp:TextBox>
                                                        </td>
                                                        <td>
                                                            <telerik:RadButton ID="btnShared" runat="server" Width="65px" Font-Underline="false"
                                                                AutoPostBack="false" CausesValidation="false" UseSubmitBehavior="false" OnClientClicking="OpenSharedSourceDialog">
                                                            </telerik:RadButton>
                                                            <asp:CustomValidator ID="cvShared" runat="server" ErrorMessage="PLEASE_CHOOSE_A_SOURCE_LOCATION"
                                                                ControlToValidate="txtPrjName" OnServerValidate="cvShared_ServerValidate" ClientValidationFunction="sharedValidation">
                                                            </asp:CustomValidator>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:RadioButton ID="rbSourceCtrl" runat="server" GroupName="Step2Options" AutoPostBack="false"
                                                    EnableViewState="false" />
                                            </td>
                                            <td>
                                                <label enableviewstate="false" id="lblSourceCtrl" runat="server" for="rbSourceCtrl">
                                                </label>
                                            </td>
                                            <td>
                                                <table>
                                                    <tr>
                                                        <td>
                                                            <asp:TextBox ID="txtSCUrl" EnableViewState="false" runat="server" Width="350"
                                                                TabIndex="1"></asp:TextBox>
                                                        </td>
                                                        <td>
                                                            <asp:TextBox ID="txtSourceCtrl" EnableViewState="false" Style="display: none" runat="server" Width="350"
                                                                TabIndex="1"></asp:TextBox>
                                                            <telerik:RadButton ID="btnSourceCtrl" AutoPostBack="false" runat="server" EnableViewState="false"
                                                                Width="65px" Font-Underline="false" CausesValidation="false" UseSubmitBehavior="false"
                                                                OnClientClicking="OpenSourceControlDialog">
                                                            </telerik:RadButton>
                                                            <asp:CustomValidator ID="cvSourceCtrl" runat="server" ErrorMessage="PLEASE_CHOOSE_A_SOURCE_LOCATION"
                                                                ControlToValidate="txtPrjName" OnServerValidate="cvSourceCtrl_ServerValidate"
                                                                ClientValidationFunction="sourceCtrlValidation">
                                                            </asp:CustomValidator>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td >
                                                            <div style="position: absolute;">
                                                                <asp:Label ID="lblBranchName" Visible="false" Text="" runat="server"></asp:Label>
                                                            </div>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:RadioButton ID="rbPulling" runat="server" GroupName="Step2Options" EnableViewState="false"
                                                    AutoPostBack="false" />
                                            </td>
                                            <td>
                                                <label enableviewstate="false" id="lblPulling" runat="server" for="rbSourceCtrl">
                                                </label>
                                            </td>
                                            <td>
                                                <table>
                                                    <tr>
                                                        <td>
                                                            <asp:TextBox ID="txtPulling" EnableViewState="false" runat="server" Width="350" TabIndex="1"></asp:TextBox>
                                                        </td>
                                                        <td>
                                                            <telerik:RadButton ID="btnPulling" runat="server" Width="65px" AutoPostBack="false"
                                                                Font-Underline="false" EnableViewState="false" CausesValidation="false" UseSubmitBehavior="false"
                                                                OnClientClicking="OpenPullingDialog">
                                                            </telerik:RadButton>
                                                            <asp:CustomValidator ID="cvPulling" runat="server" ErrorMessage="PLEASE_CHOOSE_A_SOURCE_LOCATION"
                                                                ControlToValidate="txtPrjName" OnServerValidate="cvPulling_ServerValidate" ClientValidationFunction="pullingValidation">
                                                            </asp:CustomValidator>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                                <div ng-non-bindable style="display: inline-block; padding: 20px; vertical-align: top; margin-top: 5px;">
                                    <CX:SourceFilterPatternControl runat="server" ID="SourceFilterPatternControl" />
                                </div>
                            </div>
                        </telerik:RadPageView>
                        <telerik:RadPageView ID="Step3PageView" runat="server">
                            <div class="DetailsContentContainer" style="min-height: 300px; border-bottom: none;">
                                <div style="padding: 20px 0px 20px 20px">
                                    <table cellpadding="2" cellspacing="5">
                                        <colgroup>
                                            <col width="20px" />
                                            <col width="80px" />
                                            <col width="400px" />
                                        </colgroup>
                                        <tr>
                                            <td>
                                                <asp:RadioButton ID="rbNone" runat="server" GroupName="Step3Options" EnableViewState="false"
                                                    AutoPostBack="false" />
                                            </td>
                                            <td>
                                                <label enableviewstate="false" id="lblNone" runat="server" for="rbNone">
                                                </label>
                                            </td>
                                            <td></td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:RadioButton ID="rbNow" runat="server" Checked="true" EnableViewState="false"
                                                    GroupName="Step3Options" AutoPostBack="false" />
                                            </td>
                                            <td>
                                                <label enableviewstate="false" id="lblNow" runat="server" for="rbNow">
                                                </label>
                                            </td>
                                            <td></td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:RadioButton ID="rbBySched" runat="server" GroupName="Step3Options" EnableViewState="false"
                                                    AutoPostBack="false" />
                                            </td>
                                            <td>
                                                <label enableviewstate="false" id="lblBySched" runat="server" for="rbBySched">
                                                </label>
                                            </td>
                                            <td></td>
                                        </tr>
                                        <tr>
                                            <td colspan="3">
                                                <table cellpadding="2" cellspacing="5">
                                                    <colgroup>
                                                        <col width="150" />
                                                        <col width="200" />
                                                        <col width="300" />
                                                    </colgroup>
                                                    <tr style="vertical-align: bottom;">
                                                        <td>
                                                            <label enableviewstate="false" id="lblRunOnWeekDays" runat="server" for="rbBySched">
                                                            </label>
                                                        </td>
                                                        <td>
                                                            <table cellpadding="0" cellspacing="0">
                                                                <colgroup>
                                                                    <col width="30px" />
                                                                    <col width="30px" />
                                                                    <col width="30px" />
                                                                    <col width="30px" />
                                                                    <col width="30px" />
                                                                    <col width="30px" />
                                                                    <col width="30px" />
                                                                    <col width="200px" />
                                                                </colgroup>
                                                                <tr>
                                                                    <td>
                                                                        <label enableviewstate="false" id="lblMo" runat="server" for="cbMo">
                                                                        </label>
                                                                    </td>
                                                                    <td>
                                                                        <label enableviewstate="false" id="lblTu" runat="server" for="cbTu">
                                                                        </label>
                                                                    </td>
                                                                    <td>
                                                                        <label enableviewstate="false" id="lblWe" runat="server" for="cbWe">
                                                                        </label>
                                                                    </td>
                                                                    <td>
                                                                        <label enableviewstate="false" id="lblTh" runat="server" for="cbTh">
                                                                        </label>
                                                                    </td>
                                                                    <td>
                                                                        <label enableviewstate="false" id="lblFr" runat="server" for="cbFr">
                                                                        </label>
                                                                    </td>
                                                                    <td>
                                                                        <label enableviewstate="false" id="lblSa" runat="server" for="cbSa">
                                                                        </label>
                                                                    </td>
                                                                    <td>
                                                                        <label enableviewstate="false" id="lblSu" runat="server" for="cbSu">
                                                                        </label>
                                                                    </td>
                                                                </tr>
                                                                <tr style="height: 10px">
                                                                    <td>
                                                                        <asp:CheckBox ID="cbMo" runat="server" EnableViewState="false" />
                                                                    </td>
                                                                    <td>
                                                                        <asp:CheckBox ID="cbTu" runat="server" EnableViewState="false" />
                                                                    </td>
                                                                    <td>
                                                                        <asp:CheckBox ID="cbWe" runat="server" EnableViewState="false" />
                                                                    </td>
                                                                    <td>
                                                                        <asp:CheckBox ID="cbTh" runat="server" EnableViewState="false" />
                                                                    </td>
                                                                    <td>
                                                                        <asp:CheckBox ID="cbFr" runat="server" EnableViewState="false" />
                                                                    </td>
                                                                    <td>
                                                                        <asp:CheckBox ID="cbSa" runat="server" EnableViewState="false" />
                                                                    </td>
                                                                    <td>
                                                                        <asp:CheckBox ID="cbSu" runat="server" EnableViewState="false" />
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </td>
                                                        <td>
                                                            <asp:CustomValidator ID="cvDays" runat="server" ClientValidationFunction="DaysValidation"
                                                                EnableViewState="false" />
                                                        </td>
                                                    </tr>
                                                    <tr style="vertical-align: middle; height: 20px">
                                                        <td>
                                                            <label enableviewstate="false" id="lblRunTime" runat="server" for="cbSu">
                                                            </label>
                                                        </td>
                                                        <td>
                                                            <telerik:RadTimePicker ID="TimeInput" runat="server" Width="90px" DateInput-MaxLength="5" DateInput-ClientEvents-OnDisable="fixDisableDisappear"
                                                                DateInput-DateFormat="t" Culture="en-US" EnableViewState="false">
                                                                <TimeView ID="TimeView1" runat="server" Skin="Silk" ShowHeader="False" Interval="00:30:00" Columns="4">
                                                                </TimeView>
                                                            </telerik:RadTimePicker>
                                                        </td>
                                                        <td>
                                                            <asp:CustomValidator ID="cvRunTime" runat="server" ClientValidationFunction="TimeValidation" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                        </telerik:RadPageView>                       
                        <telerik:RadPageView ID="Step4PageView" runat="server">
                            <div class="DetailsContentContainer" style="min-height: 410px; border-bottom: none;">
                                <div style="padding: 20px 0px 20px 20px">
                                    <table cellpadding="2" cellspacing="5">
                                        <tr style="vertical-align: middle">
                                            <td>
                                                <label enableviewstate="false" id="lblBeforeStartScan" runat="server" for="txtBeforeStartScan" />
                                                <asp:CustomValidator ID="cvBeforeScanStart" runat="server" ClientValidationFunction="ValidateEmails"
                                                    EnableViewState="false" ControlToValidate="txtBeforeStartScan" SetFocusOnError="true"
                                                    Display="Dynamic"></asp:CustomValidator>
                                                <br />
                                                <asp:TextBox ID="txtBeforeStartScan" runat="server" Width="450" Height="45px" EnableViewState="false"
                                                    TextMode="MultiLine"></asp:TextBox>
                                            </td>
                                            <td>
                                                <img style="margin-top: 15px;" alt="" id="imgBeforeScan" width="24" height="24" src="Images/Icons/AddRecipientIcon.png" />
                                            </td>
                                        </tr>
                                        <tr style="vertical-align: middle">
                                            <td>
                                                <label enableviewstate="false" id="lblAfterScanSucceds" runat="server" for="txtAfterScanSucceds" />
                                                <asp:CustomValidator ID="cvAfterScanSucceds" runat="server" ClientValidationFunction="ValidateEmails"
                                                    EnableViewState="false" ControlToValidate="txtAfterScanSucceds" SetFocusOnError="true"></asp:CustomValidator>
                                                <br />
                                                <asp:TextBox ID="txtAfterScanSucceds" runat="server" Width="450" Height="45px" TabIndex="1"
                                                    TextMode="MultiLine" EnableViewState="false"></asp:TextBox>
                                            </td>
                                            <td>
                                                <img style="margin-top: 15px;" alt="" id="imgAferScan" width="24" height="24" src="Images/Icons/AddRecipientIcon.png" />
                                            </td>
                                        </tr>
                                        <tr style="vertical-align: middle">
                                            <td>
                                                <label enableviewstate="false" id="lblScanFailed" runat="server" for="txtScanFailed" />
                                                <br />
                                                <asp:CustomValidator ID="cvScanFailed" runat="server" EnableViewState="false" ClientValidationFunction="ValidateEmails"
                                                    ControlToValidate="txtScanFailed" SetFocusOnError="true"></asp:CustomValidator>
                                                <asp:TextBox ID="txtScanFailed" runat="server" Width="450" EnableViewState="false"
                                                    Height="45px" TabIndex="1" TextMode="MultiLine"></asp:TextBox>
                                            </td>
                                            <td>
                                                <img style="margin-top: 15px;" alt="" id="imgFailedScan" width="24" height="24" src="Images/Icons/AddRecipientIcon.png" />
                                            </td>
                                        </tr>
                                        <tr style="vertical-align: middle">
                                            <td>
                                                <label enableviewstate="false" id="Commands" runat="server" for="PostScanList" />
                                                <br />
                                                <telerik:RadComboBox ng-non-bindable ID="PostScanList" runat="server" Width="450" Skin="Silk" AutoCompleteSeparator=";"
                                                    MarkFirstMatch="True">
                                                </telerik:RadComboBox>
                                            </td>
                                        </tr>
                                        <tr style="vertical-align: middle" runat="server" id="itsrow">
                                            <td>                                                
                                                <label enableviewstate="false" id="lblIssueTracking" runat="server" class="Grey"></label>
                                                <br />
                                                <telerik:RadComboBox ng-non-bindable ID="cmbIssueTracking" CssClass="marginLeft-2" runat="server" Width="450" Skin="Silk" onclientselectedindexchanged="openITS" />
                                            </td>

                                            <td>
                                                <br />
                                                 <telerik:RadButton ID="btnITSopen" runat="server" EnableViewState="false" OnClientClicked="openITS"
                                                                CausesValidation="false" UseSubmitBehavior="false" AutoPostBack="false">
                                                                <Icon SecondaryIconCssClass="rbOk" SecondaryIconRight="4" SecondaryIconTop="4" />
                                                </telerik:RadButton>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                        </telerik:RadPageView>
                        <telerik:RadPageView ID="Step5PageView" runat="server">
                             <div class="DetailsContentContainer" style="min-height: 50px; border-bottom: none;">
                                 <div style="padding: 5px 0 20px 20px">
                                     <div class="WizardPageInner" style="padding-top: 15px">
                                         <div class="customFieldContainer">
                                             <asp:Repeater ID="customFieldRepeater" runat="server">
                                                 <ItemTemplate>
                                                     <div ng-non-bindable class="customField">
                                                         <label title='<%# Eval("FieldName").ToString() %>' class="customFieldNameLabel"><%# Eval("FieldName").ToString() %></label>
                                                         <input runat="server" id="customFieldValue" type="text"
                                                             field-id='<%# Eval("FieldId").ToString() %>'
                                                             class="customFieldValue"
                                                             placeholder='<%# Eval("FieldName").ToString() %>'
                                                             value='<%# Eval("Value").ToString() %>' maxlength="256" />
                                                     </div>
                                                 </ItemTemplate>
                                             </asp:Repeater>
                                         </div>
                                         <div class="customFieldNotDefined" runat="server" id="CustomFieldNotDefinedLabel"><%= GetTermFromResource("CUSTOM_FIELDS_NOT_DEFINED") %></div>
                                         <div class="customFieldGeneralError" runat="server" id="CustomFieldGeneralError"><%= GetTermFromResource("CUSTOM_FIELDS_GENERAL_ERROR") %></div>
                                     </div>
                                 </div>
                             </div>
                        </telerik:RadPageView>
                        <telerik:RadPageView ID="Step6PageView" runat="server">
                             <div class="DetailsContentContainer" style="min-height: 50px; border-bottom: none;">
                                 <div style="padding: 5px 0 20px 20px">
                                     <div class="WizardPageInner" style="padding-top: 15px">
                                        <div class="dataRetentionContainer">
                                            <div style="margin: 0 auto; padding: 20px 0;">
                                                <label id="lblNumOfScansToKeep" runat="server" for="inputScansToKeep"><%= GetTermFromResource("NEW_PROJECT_STEP6_NUM_OF_SCANS_LABEL") %></label>
                                                <input id="inputScansToKeep" runat="server" type="text" style="width: 100px; margin-left: 10px; margin-right: 10px;" />
                                                <asp:RangeValidator ID="NumOfScansToKeepRangeValidator" runat="server" ControlToValidate="inputScansToKeep" MinimumValue="1" MaximumValue="10000" Type="Integer"></asp:RangeValidator>
                                            </div>
                                        </div>                                       
                                     </div>
                                 </div>
                             </div>
                        </telerik:RadPageView>
                         <telerik:RadPageView ID="Step7PageView" runat="server">
                            <div class="DetailsContentContainer" style="min-height: 300px; border-bottom: none;">
                                <div style="display: inline-block; padding: 20px;" >
                                    <div runat="server" id="divOSATabSpinner">
                                        <img id="imgTestConnectionSpinner" alt="" src="images/icons/loader16x16.gif" style="margin-left: 300px; margin-top: 100px; vertical-align: middle;" />
                                    </div>
                                    <div runat="server" id="disOSATabEulaNotAccepted" style="display:none; width:600px; text-align:center;font-size:14px;">
                                        <img alt="" runat="Server" id="imgScans" width="58" height="58" style="margin-top:65px; margin-bottom:15px;" src="app/styles/images/no_license.png" />
                                        <div><%= GetTermFromResource("OSA_SETTINGS_ACCEPT_EULA") %></div>
                                    </div>
                                    <div runat="server" id="divOSATab" style="display:none">
                                        <label enableviewstate="false" id="lblOSATitle" style="font-weight:bold;" runat="server"></label>
                                        <table cellpadding="2" cellspacing="5" border="0">
                                            <colgroup>
                                                <col width="20px" />
                                                <col width="100px" />
                                            </colgroup>
                                            <tr>
                                                <td>
                                                    <asp:RadioButton id="rbOsaOriginLocal" ClientIDMode="Static" runat="server" EnableViewState="false" GroupName="osaLocation" onclick="OsaLocationChanged(this);"></asp:RadioButton>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:RadioButton id="rbOsaOriginShared" ClientIDMode="Static" runat="server" EnableViewState="false" GroupName="osaLocation"
                                                                     onclick="OsaLocationChanged(this);"></asp:RadioButton>
                                                </td>
                                                <td>
                                                    <table>
                                                        <tr>
                                                            <td>
                                                                <asp:TextBox ID="txtOSAShared" ClientIDMode="Static" runat="server" Width="350" EnableViewState="false" TabIndex="1" />                                                            
                                                            </td>
                                                            <td>
                                                                <telerik:RadButton ID="btnOSAShared" ClientIDMode="Static" runat="server" Width="65px" Font-Underline="false"
                                                                    AutoPostBack="false" CausesValidation="false" UseSubmitBehavior="false" OnClientClicking="OpenSharedOpenSourceDialog">
                                                                </telerik:RadButton>
                                                                <asp:CustomValidator ID="cvOsaShared" runat="server" ErrorMessage="PLEASE_CHOOSE_A_SOURCE_LOCATION"
                                                                    ControlToValidate="txtPrjName" OnServerValidate="cvOsaShared_ServerValidate" ClientValidationFunction="osaSharedValidation">
                                                                </asp:CustomValidator>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                        </table>
                                        
                                        <label enableviewstate="false" id="lblOsaPreScanTitle" style="font-weight:bold; margin-top: 15px; display:inline-block;" runat="server"></label>
                                        <table cellpadding="2" cellspacing="5" border="0">
                                        <colgroup>
                                            <col width="20px" />
                                            <col width="100px" />
                                        </colgroup>
                                        <tr>
                                            <td>
                                                <asp:CheckBox id="enableOsaResolveDependencies" ClientIDMode="Static" runat="server" 
                                                                 EnableViewState="false" GroupName="osaLocation" OnClick="setOsaSettingsChecked()" ></asp:CheckBox>
                                            </td>
                                        </tr>
                                        </table>
                                    </div>
                                     <div runat="server" id="divOSANoLicense"><%= GetTermFromResource("NEW_PROJECT_STEP7_NO_OPEN_SOURCE_ANALYSIS_LICENSE") %> </div>
                                </div>
                            </div>
                        </telerik:RadPageView>
                        

                    </telerik:RadMultiPage>
                    <div class="DetailsContentContainer" style="background-color: #F7F7F7; min-height: 33px; padding-left: 25px; z-index: 2">
                        <table cellpadding="2" cellspacing="2" border="0">
                            <tr>
                                <td>
                                    <telerik:RadButton ID="btnUpdate" runat="server" EnableViewState="false" CausesValidation="true"
                                        OnClick="btnUpdate_Click" OnClientClicking="updateClick" UseSubmitBehavior="true">
                                        <Icon SecondaryIconCssClass="rbOk" SecondaryIconRight="4" SecondaryIconTop="4" />
                                    </telerik:RadButton>
                                    <span runat="server" id="lblProjectGeneralError" class="projectGeneralError"></span>
                                </td>
                                <td>
                                    <telerik:RadButton ID="btnCancel" runat="server" OnClientClicking="updateClick" EnableViewState="false"
                                        Style="display: none" CausesValidation="false" UseSubmitBehavior="true" AutoPostBack="true">
                                        <Icon SecondaryIconCssClass="rbCancel" SecondaryIconRight="4" SecondaryIconTop="4" />
                                    </telerik:RadButton>
                                </td>
                            </tr>
                        </table>
                    </div>
                </asp:Panel>
                <div class="noselectedbox" id="pnlNoRecord" enableviewstate="false" runat="server">
                    <div class="noselectedrecord" id="lblNoRecord" enableviewstate="false" runat="server">
                    </div>
                </div>
            </asp:Panel>
        </div>
    </div>
</asp:Content>

<asp:Content ID="cnt3" ContentPlaceHolderID="script" runat="Server">

    <script language="javascript" type="text/javascript">
        function DaysValidation(sender, args) {
            if ($get('<%=rbBySched.ClientID%>').checked) {
                args.IsValid = ($get('<%=cbMo.ClientID%>').checked ||
                    $get('<%=cbTu.ClientID%>').checked ||
                    $get('<%=cbWe.ClientID%>').checked ||
                    $get('<%=cbTh.ClientID%>').checked ||
                    $get('<%=cbFr.ClientID%>').checked ||
                    $get('<%=cbSa.ClientID%>').checked ||
                    $get('<%=cbSu.ClientID%>').checked);
            }
        }

        function TimeValidation(sender, args) {
            args.IsValid = true;
        }

        function ensureDetailsPanelVisible() {
            return !$telerik.$('#<%=pnlNoRecord.ClientID%>').is(':visible');
        }

        Sys.Application.add_load(function () { EnableDetailFrame(false) });

        Sys.Application.add_load(initAutoComplete);
    </script>

</asp:Content>
