<%@ Page Title="" Language="C#" MasterPageFile="~/MainMaster.master" AutoEventWireup="true" Inherits="Scans" CodeBehind="Scans.aspx.cs" %>

<%@ Register TagPrefix="CX" Assembly="CxWebClientApp" Namespace="CxControls" %>

<asp:Content ID="cnt1" ContentPlaceHolderID="head" runat="Server">
    <%= System.Web.Optimization.Scripts.Render("~/portal/Scripts/lockScan") %>
    <style type="text/css">
        .availableAction{
            display:inline-block;
        }

        .unavailableAction{
            display:none;
        }

        .scan-state-icon,
        .box-content input[type=checkbox]{
            vertical-align:middle;
        }

    </style>
    <script type="text/javascript">

        var toolbarBtn = null;
        var DELETE_SCANS_CONFIRMATION = "<%=this.GetTermFromResourceJSEncoded("DELETE_SCANS_CONFIRMATION")%>";
        var COMPARE_PROJECTS_CONFIRMATION = "<%=this.GetTermFromResourceJSEncoded("COMPARE_TWO_PROJECTS_CONFIRMATION")%>";
        var DELETE_SCANS_SUCCESSFULLY = "<%=this.GetTermFromResourceJSEncoded("DELETE_SCANS_SUCCESSFULLY")%>"; 
        var DELETE_SCANS_PARTLY_SUCCESSFUL = "<%=this.GetTermFromResourceJSEncoded("DELETE_SCANS_PARTLY_SUCCESSFUL")%>";
        var DELETE_SCANS_DOWNLOAD_FILE = "<%=this.GetTermFromResourceJSEncoded("DELETE_SCANS_DOWNLOAD_FILE")%>";
        var SELECT_SCANS_2_DELETE = "<%=this.GetTermFromResourceJSEncoded("SELECT_SCANS_2_DELETE")%>";
        var DELETE_SCANS_DOWNLOAD_TEXT = "<%=this.GetTermFromResourceJSEncoded("DELETE_SCANS_DOWNLOAD_TEXT")%>";
        var OK = "<%=this.GetTermFromResourceJSEncoded("OK")%>";
        
        var oldCmmts = "";

        function onRequestStart(sender, args) {

            requestStart(sender, args);

            if (args.get_eventTarget().indexOf("_GridToolbar") >= 0) {
                if (toolbarBtn.get_value() != "REFRESH") {
                    args.set_enableAjax(false);
                }
            }
        }

        function onClientButtonClicking(sender, args) {
            toolbarBtn = args.get_item();
            if (args.get_item().get_value() == '<%=k_DeleteProjectsValue%>') {
                args.set_cancel(true);
                deleteScans(false);
            } else if (args.get_item().get_value() == '<%=k_CompareScansValue%>') {
                compareScans(args.get_domEvent(), false);
                args.set_cancel(true);
            }
        }

        function compareScans(e, isConfirmed) {            
            var grid = $find("<%=ScansGrid.ClientID %>");
            var scansIDs = new Array();
            var items = grid.get_seletedCheckboxItems();

            for (var i = 0; i < items.length; i++) {
                var scanid = items[i].getDataKeyValue("ScanID");
                var projectid = items[i].getDataKeyValue("ProjectID");
                scansIDs.push({scanId: scanid, projectId: projectid});
            }

            if (scansIDs.length != 2) {
                openInfo("<%=this.GetTermFromResourceJSEncoded("SELECT_TWO_SCANS_2_COMPARE")%>", e)
            }
            else {
                if (!isConfirmed && scansIDs[0].projectId != scansIDs[1].projectId) {
                    openConfirm(COMPARE_PROJECTS_CONFIRMATION, null, function () { compareScans(e, true); });
                    return;
                }

                var oldScan = parseInt(scansIDs[0].scanId) > parseInt(scansIDs[1].scanId) ? scansIDs[1] : scansIDs[0];
                var newScan = parseInt(scansIDs[0].scanId) > parseInt(scansIDs[1].scanId) ? scansIDs[0] : scansIDs[1];

                var oWnd = radopen("popScanCompare.aspx?id1=" + newScan.scanId + "&id2=" + oldScan.scanId + "&pid1=" + newScan.projectId + "&pid2=" + oldScan.projectId);
                oWnd.setSize(1295, 915);
                oWnd.center();
                oWnd.show();
            }
        }

function deleteScans(isConfirmed, flags) {
    var scanIDs = new Array();
    var items = $find('<%=ScansGrid.ClientID%>').get_seletedCheckboxItems();
        for (var i = 0; i < items.length; i++) {
            var id = items[i].getDataKeyValue("ScanID");
            scanIDs.push(id);
        }

        if (scanIDs.length == 0) {
            openInfo(SELECT_SCANS_2_DELETE);
            return;
        } else if (!isConfirmed) {
            var message = String.format(DELETE_SCANS_CONFIRMATION, scanIDs.length);
            openConfirm(message, null, function () { deleteScans(true, flags); });
            return;
        }

        flags = flags || '<%=CxWebClientApp.CxWebServices.DeleteFlags.None %>';

    $telerik.$.ajax({
        type: 'POST',
        async: false,
        url: 'Scans.aspx/DeleteScans',
        data: '{\'scanIdsToDelete\':' + JSON.stringify(scanIDs) +
              ',\'flags\':\'' + flags + '\'}',
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (response) {
            if (response.d == null) {
                top.location.href = 'Login.aspx?logout=true';
            } else if (response.d.IsSuccessful) {
                $find('<%=ScansGrid.ClientID%>').get_masterTableView().rebind();
            } else if (response.d.UndeletedScans != null && response.d.UndeletedScans.length > 0) {
                $find('<%=ScansGrid.ClientID%>').get_masterTableView().rebind();
                var title = DELETE_SCANS_PARTLY_SUCCESSFUL.replace('{0}', response.d.NumOfDeletedScans).replace('{1}', response.d.NumOfDeletedScans + response.d.UndeletedScans.length);
                showDeleteObjectsPopup(response.d.UndeletedScans, response.d.NumOfDeletedScans, title, DELETE_SCANS_DOWNLOAD_TEXT, OK, DELETE_SCANS_DOWNLOAD_FILE, true);
            }
            else if (response.d.IsConfirmation) {
                openConfirm(response.d.ErrorMessage, null, function () { deleteScans(true, response.d.Flags); });
            } else {
                openInfo(response.d.ErrorMessage, null);
            }
        }
    });
}

function ScanRowSelected(sender, eventArg) {
    var selectedScan = eventArg.getDataKeyValue("ScanID");
    $get("<%=hdnSelectedScan.ClientID%>").value = selectedScan;
    $telerik.$("#<%=btnScanDetail.ClientID%>").trigger('click');
}

function updateCmmts(button, args) {
    if ($get("<%=hdnSelectedScan.ClientID%>").value > "") {
        if (button.get_text() == "<%=this.GetTermFromResourceJSEncoded("EDIT")%>") {
            button.set_text("<%=this.GetTermFromResourceJSEncoded("UPDATE")%>");
            button.set_autoPostBack(false);
            $telerik.$("#<%=txtCmmts.ClientID%>").removeAttr("disabled");
            $get("<%=txtCmmts.ClientID%>").focus();
            oldCmmts = $get("<%=txtCmmts.ClientID%>").value;
            $telerik.$("#<%=btnCancel.ClientID%>").show();
        }
        else {
            button.set_autoPostBack(true);
        }
    }
    else {
        button.set_autoPostBack(false);
    }
}

function cancelCmmts(button, args) {
    $find("<%=btnUpdate.ClientID%>").set_text("<%=this.GetTermFromResourceJSEncoded("EDIT")%>");
    $telerik.$("#<%=txtCmmts.ClientID%>").attr("disabled", "disabled");
    $get("<%=txtCmmts.ClientID%>").value = oldCmmts;
    $telerik.$("#<%=btnCancel.ClientID%>").hide();
}

function ConfirmWindow(i_Msg, i_Event) {
    var e = $telerik.$.event.fix(i_Event || window.event);
    openConfirm(i_Msg, i_Event, function () { eval($telerik.$(e.currentTarget ? e.currentTarget : e.srcElement.parentNode).attr('href')); });
}

function openReport(i_Type, i_ScanID, i_ProjectID, i_ProjectName, i_ScanDate) {
    if (i_Type != "VIEWER") {
        var win = radopen("GenerateScanReportNew.aspx?scanid=" + i_ScanID + "&projectid=" + i_ProjectID + "&ProjectName=" + encodeURIComponent(i_ProjectName));
        win.set_visibleTitlebar(false);
        win.set_modal(true);
        win.setSize(1000, 720);
        win.center();
    }
    else {
        window.open("ViewerMain.aspx?scanId=" + i_ScanID + "&ProjectID=" + i_ProjectID);
    }
}

        function openSummery(i_ScanID, i_ProjectName, i_ProjectID, ScanCompletedStatus) {
            var oWnd = radopen("popScanSummery.aspx?ProjectId=" + i_ProjectID + "&ScanID=" + i_ScanID + "&ProjectName=" + "&rnd=" + Math.random());
            var height = 895;
            if (ScanCompletedStatus == 2)
                height += 40;
            oWnd.setSize(1160, height);
    oWnd.center();
}

function filterScanScopeSelectedIndexChanged(sender, args) {
    try {
        var tableView = $find('<%=ScansGrid.ClientID %>').get_masterTableView();
        if (args.get_item().get_value() == "") {
            tableView.filter("ScanScope", "", "NoFilter");
        } else {
            tableView.filter("ScanScope", args.get_item().get_value(), "EqualTo");
        }
    }
    catch (e) {
    }
}

		function refresh() {
            $find("ctl00_cpmain_ScansGrid").MasterTableView.rebind();
        }
    </script>

</asp:Content>
<asp:Content ID="cnt2" ContentPlaceHolderID="cpmain" runat="Server">
    <telerik:RadAjaxLoadingPanel ID="pnlLoading" runat="server" Skin="Silk">
    </telerik:RadAjaxLoadingPanel>
    <telerik:RadAjaxManager ID="ajaxMngr" runat="server" ClientEvents-OnRequestStart="onRequestStart" DefaultLoadingPanelID="pnlLoading">
        <AjaxSettings>
            <telerik:AjaxSetting AjaxControlID="ScansGrid">
                <UpdatedControls>
                    <telerik:AjaxUpdatedControl ControlID="ScansGrid" />
                    <telerik:AjaxUpdatedControl ControlID="pnlWrapper" />
                </UpdatedControls>
            </telerik:AjaxSetting>
            <telerik:AjaxSetting AjaxControlID="btnUpdate">
                <UpdatedControls>
                    <telerik:AjaxUpdatedControl ControlID="pnlDetails" />
                    <telerik:AjaxUpdatedControl ControlID="ScansGrid" />
                </UpdatedControls>
            </telerik:AjaxSetting>
            <telerik:AjaxSetting AjaxControlID="btnScanDetail">
                <UpdatedControls>
                    <telerik:AjaxUpdatedControl ControlID="pnlWrapper" />
                </UpdatedControls>
            </telerik:AjaxSetting>
        </AjaxSettings>
    </telerik:RadAjaxManager>
    <div class="box">
        <div class="box-content" style="min-height: 600px; padding-right: 2px;">
            <CX:CxGrid ID="ScansGrid" runat="server" ShowGroupPanel="true" AllowSorting="True"
                ExportHiddenColumnsList="Action,ScanLogs" MultiSelectionCheckboxes="true"
                AllowPaging="true" AllowCustomPaging="true" PagerStyle-AlwaysVisible="true" VirtualItemCount="1000"
                AllowFilteringByColumn="True" EnableViewState="true" EnableLinqExpressions="false"				>
                <MasterTableView AutoGenerateColumns="false" DataKeyNames="ScanID, ProjectID" ClientDataKeyNames="ScanID, ProjectID, IsLocked"
                    GroupLoadMode="Client" ShowHeadersWhenNoRecords="true" EnableNoRecordsTemplate="true"
                    AllowAutomaticInserts="false">
                    <Columns>
                        <telerik:GridTemplateColumn HeaderStyle-Width="35" AllowFiltering="True" HeaderStyle-CssClass="rgHeaderNoBorderRight" DataField="ScanScope" UniqueName="ScanScope" Resizable="false" Groupable="False">
                            <ItemStyle VerticalAlign="Middle" HorizontalAlign="Center" />
                            <FilterTemplate>
                                <telerik:RadComboBox ID="cmbScanScope" Width="90%" AppendDataBoundItems="true" DropDownWidth="150px"
                                    SelectedValue='<%# ((GridItem)Container).OwnerTableView.GetColumn("ScanScope").CurrentFilterValue %>'
                                    OnClientSelectedIndexChanged="filterScanScopeSelectedIndexChanged" Font-Bold="true"
                                    Font-Size="8" runat="server" MarkFirstMatch="true">
                                </telerik:RadComboBox>
                            </FilterTemplate>
                            <ItemTemplate>
                                <img alt="inc" src="Images/Icons/<%#CxScansScreenDataHelper.GetScanScopeIcon((ScanScope)DataBinder.Eval(Container.DataItem, "ScanScope"))%>" 
                                    class="scan-state-icon"/>
                            </ItemTemplate>
                        </telerik:GridTemplateColumn>
                            
                        <telerik:GridDateTimeColumn DataField="ScanDate" UniqueName="ScanDate" SortExpression="ScanDate"
                            AllowFiltering="true" DataType="System.DateTime" AutoPostBackOnFilter="true"
                            CurrentFilterFunction="GreaterThanOrEqualTo">
                        </telerik:GridDateTimeColumn>
                      
                        <telerik:GridDateTimeColumn DataField="ScanFinishDate" UniqueName="ScanFinishDate"
                            SortExpression="ScanFinishDate" DataType="System.DateTime" CurrentFilterFunction="LessThanOrEqualTo">
                        </telerik:GridDateTimeColumn>
                         <telerik:GridTemplateColumn DataField="ProjectName" UniqueName="ProjectName" SortExpression="ProjectName" 
                              AllowFiltering="true" AutoPostBackOnFilter="true" CurrentFilterFunction="Contains">
                                 <ItemTemplate><%#CxPortalHttpSanitizer.Instance.SanitizeResponseSplitting(DataBinder.Eval(Container.DataItem, "ProjectName").ToString())%></ItemTemplate>
                               </telerik:GridTemplateColumn>
                        <telerik:GridBoundColumn DataField="InitiatorName" UniqueName="InitiatorName" SortExpression="InitiatorName"
                            AllowFiltering="true" AutoPostBackOnFilter="true" CurrentFilterFunction="Contains">
                        </telerik:GridBoundColumn>
                        <telerik:GridBoundColumn DataField="Origin" UniqueName="Origin" SortExpression="Origin"
                            AllowFiltering="true" AutoPostBackOnFilter="true" CurrentFilterFunction="Contains">
                        </telerik:GridBoundColumn>
                        <telerik:GridTemplateColumn DataField="RiskLevelScore" HeaderStyle-Width="170px"
                            UniqueName="RiskLevelScore" SortExpression="RiskLevelScore" AllowFiltering="true"
                            AutoPostBackOnFilter="true" CurrentFilterFunction="NoFilter" DataType="System.Int32"
                            Groupable="True" GroupByExpression="RiskLevelScore Group By RiskLevelScore">
                            <ItemStyle VerticalAlign="Middle" HorizontalAlign="Center" />
                            <ItemTemplate>
                                <div id="divScanRisk" runat="server" enableviewstate="false" />
                                <span id="spnScanRisk" runat="server" enableviewstate="false" style="padding-top: 5px; min-width: 20px; text-align: left" />
                            </ItemTemplate>
                        </telerik:GridTemplateColumn>
                        <telerik:GridBoundColumn DataField="LOC" UniqueName="LOC"
                            SortExpression="LOC" AllowFiltering="true" AutoPostBackOnFilter="true"
                            CurrentFilterFunction="EqualTo" DataType="System.Int32">
                        </telerik:GridBoundColumn>
                          <telerik:GridBoundColumn DataField="SuccessRate" UniqueName="SuccessRate"
                            SortExpression="SuccessRate" AllowFiltering="true" AutoPostBackOnFilter="true"
                            CurrentFilterFunction="EqualTo" DataType="System.Int32">
                        </telerik:GridBoundColumn>
                        <telerik:GridBoundColumn DataField="TeamName" UniqueName="TeamName"
                            SortExpression="TeamName" AllowFiltering="true" AutoPostBackOnFilter="true"
                            CurrentFilterFunction="Contains">
                        </telerik:GridBoundColumn>
                        <telerik:GridBoundColumn DataField="ServerName" UniqueName="ServerName" SortExpression="ServerName"
                            AllowFiltering="true" AutoPostBackOnFilter="true" CurrentFilterFunction="Contains">
                        </telerik:GridBoundColumn>
                         <telerik:GridBoundColumn DataField="CxVersion" UniqueName="CxVersion" SortExpression="CxVersion"
                            AllowFiltering="true" AutoPostBackOnFilter="true" CurrentFilterFunction="Contains">
                        </telerik:GridBoundColumn>
                        <telerik:GridBoundColumn DataField="Comments" UniqueName="Comments" HtmlEncode="true"
                            SortExpression="Comments" AllowFiltering="true" AutoPostBackOnFilter="true"
                            CurrentFilterFunction="Contains">
                        </telerik:GridBoundColumn>
                        <telerik:GridTemplateColumn UniqueName="Access" SortExpression="Access" DataField="Access" DataType="System.Boolean" 
                            AllowFiltering="true" AutoPostBackOnFilter="true" CurrentFilterFunction="EqualTo">
                            <ItemTemplate>
                                <asp:Label runat="server" Text='<%# Convert.ToString(Eval("Access")) == "PUBLIC" ? GetTermFromResource("PUBLIC") : GetTermFromResource("PRIVATE") %>'></asp:Label>
                            </ItemTemplate>
                        </telerik:GridTemplateColumn>
                        <telerik:GridTemplateColumn UniqueName="IsLocked" SortExpression="IsLocked" DataField="IsLocked" DataType="System.Boolean"
                            AllowFiltering="true" AutoPostBackOnFilter="true" CurrentFilterFunction="EqualTo">
                            <ItemTemplate>
                                <asp:Label runat="server" Text='<%# Convert.ToBoolean(Eval("IsLocked")) == true ? GetTermFromResource("LOCKED") : string.Empty %>'></asp:Label>
                            </ItemTemplate>
                        </telerik:GridTemplateColumn>
                        <telerik:GridTemplateColumn UniqueName="Action" Groupable="False" AllowFiltering="false">
                            <ItemTemplate>
                                <div style="vertical-align: middle; cursor: pointer;">
                                    <img id="imgViewer" style="margin-bottom:-2px;" runat="server" enableviewstate="false" alt="" src="images/ico/Search.png" />&nbsp;
                                    <img id="imgReports" style="margin-bottom:-2px;" runat="server" enableviewstate="false" alt="" src="images/icons/reports16x16.png" />&nbsp;
                                    <img id="imgSummery" runat="server" enableviewstate="false" alt="" src="images/ico/form-submit.png" />&nbsp;
                                    <img runat="server" Visible='<%# PortalUser.IsAllowedToDeleteScan %>' src="images/icons/unlocked.png" title='<%# GetTermFromResource("LOCK_SCAN") %>' class='<%# Convert.ToString(Eval("Access")) == "PUBLIC" && Convert.ToBoolean(Eval("IsLocked")) == false ? "availableAction" : "unavailableAction" %>' onclick='<%# ("lockScan(" + Eval("ScanID") + ", refresh)") %>' />
                                    <img runat="server" Visible='<%# PortalUser.IsAllowedToDeleteScan %>' src="images/icons/locked.png" title='<%# GetTermFromResource("UNLOCK_SCAN") %>' class='<%# Convert.ToString(Eval("Access")) == "PUBLIC" && Convert.ToBoolean(Eval("IsLocked")) == true ? "availableAction" : "unavailableAction" %>' onclick='<%# ("unlockScan(" + Eval("ScanID") + ", refresh)") %>' />
                                </div>
                            </ItemTemplate>
                            <HeaderStyle Width="100px"></HeaderStyle>
                        </telerik:GridTemplateColumn>
                        <telerik:GridTemplateColumn HeaderStyle-Width="35" AllowFiltering="false" UniqueName="ScanLogs" Groupable="False">
                            <ItemStyle VerticalAlign="Middle" HorizontalAlign="Center" />
                            <ItemTemplate>
                                <CX:CxLogsDownloadButton ID="lbScanLogs" runat="server" StreamLogData-ScanType="Finished" Visible='<%# (this.Page as CxPortalPage).PortalUser.IsScanner %>' StreamLogData-Id='<%# (long)DataBinder.Eval(Container.DataItem, "ScanID") %>' StreamLogData-ProjectName='<%# HttpUtility.UrlEncode(DataBinder.Eval(Container.DataItem, "ProjectName").ToString()) %>' StreamLogData-ScanTime='<%# DataBinder.Eval(Container.DataItem, "ScanFinishDate") %>'>
                                </CX:CxLogsDownloadButton>
                            </ItemTemplate>
                        </telerik:GridTemplateColumn>
                    </Columns>
                </MasterTableView>
                <ClientSettings ReorderColumnsOnClient="True" AllowDragToGroup="True" AllowColumnsReorder="True"
                    AllowGroupExpandCollapse="true">
                    <Resizing AllowRowResize="false" AllowColumnResize="True" EnableRealTimeResize="True"
                        ResizeGridOnColumnResize="False"></Resizing>
                    <Selecting AllowRowSelect="true" />
                    <ClientEvents OnRowSelected="ScanRowSelected"></ClientEvents>
                    <ClientEvents OnMasterTableViewCreated="MTVCreated" />                    
                    <ClientEvents OnCommand="GridCommand" />
                </ClientSettings>
                <GroupingSettings ShowUnGroupButton="true" />
                <PagerStyle AlwaysVisible="True" Mode="NextPrevAndNumeric" />
                <ExportSettings Pdf-PaperSize="A4" Pdf-PageTitle="Scans" Pdf-PageHeight="210mm" Pdf-PageWidth="297mm" FileName="Scans">
                </ExportSettings>
            </CX:CxGrid>
            <br />
            <asp:Panel ID="pnlWrapper" runat="server">
                <div style="display: none">
                    <asp:HiddenField ID="hdnSelectedScan" EnableViewState="false" runat="server" />
                    <asp:Button ID="btnScanDetail" runat="server" OnClick="btnScanDetail_Click" EnableViewState="false" />
                </div>
                <asp:Panel ID="pnlDetails" runat="server">
                    <telerik:RadTabStrip ID="ScanTabStrip" runat="server" MultiPageID="ScanMultiPage"
                        SelectedIndex="0" Skin="Silk">
                        <Tabs>
                            <telerik:RadTab PageViewID="MonitorPagev" Text="Monitoring">
                            </telerik:RadTab>
                            <telerik:RadTab PageViewID="CmmtsPagev" Text="Comments">
                            </telerik:RadTab>
                        </Tabs>
                    </telerik:RadTabStrip>
                    <telerik:RadMultiPage ID="ScanMultiPage" runat="server" SelectedIndex="0">
                        <telerik:RadPageView ID="MonitorPagev" runat="server">
                            <div class="DetailsContentContainer" style="background-color:#FDFDFD; height: 305px;">
                                <div style="padding: 1px 10px 10px 20px">
                                    <table cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td>
                                                <fieldset>
                                                    <legend id="lblScanVulner" enableviewstate="false" runat="server"></legend>
                                                    <telerik:RadChart ID="ScanVulnerabilitiesChart" EnableViewState="false" runat="server"
                                                        Width="300px" Height="200px" Skin="Web20" AutoLayout="true" AutoTextWrap="true">
                                                        <Legend>
                                                            <Appearance>
                                                                <ItemAppearance Visible="false">
                                                                </ItemAppearance>
                                                            </Appearance>
                                                        </Legend>
                                                        <ChartTitle>
                                                            <Appearance Visible="false">
                                                            </Appearance>
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
                                                                </Appearance>
                                                            </YAxis>
                                                            <XAxis>
                                                                <AxisLabel>
                                                                    <TextBlock Visible="false">
                                                                    </TextBlock>
                                                                </AxisLabel>
                                                                <Appearance MajorGridLines-Visible="true" MajorTick-Visible="true" MinorTick-Visible="true"
                                                                    MinorGridLines-Visible="false" LabelAppearance-Visible="true">
                                                                </Appearance>
                                                            </XAxis>
                                                            <Appearance Dimensions-Margins="20px" Dimensions-Paddings="0px">
                                                                <Border Visible="true" />
                                                            </Appearance>
                                                        </PlotArea>
                                                    </telerik:RadChart>
                                                </fieldset>
                                            </td>
                                            <td>
                                                <fieldset>
                                                    <legend id="lblScanRisk" enableviewstate="false" runat="server"></legend>
                                                    <telerik:RadChart ID="ScanRiskChart" runat="server" EnableViewState="false" IntelligentLabelsEnabled="true"
                                                        Width="300px" Height="200px" Skin="Silk">
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
                                                            <Appearance Dimensions-Margins="20px" Dimensions-Paddings="0px">
                                                                <FillStyle FillType="Image" FillSettings-BackgroundImage="Images/Common/Graph.jpg"
                                                                    FillSettings-ImageAlign="Top" FillSettings-ImageDrawMode="Stretch">
                                                                    <FillSettings BackgroundImage="Images/Common/Graph.jpg" ImageAlign="Top">
                                                                    </FillSettings>
                                                                </FillStyle>
                                                                <Border Visible="true" />
                                                            </Appearance>
                                                        </PlotArea>
                                                    </telerik:RadChart>
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
                        <telerik:RadPageView ID="CmmtsPagev" runat="server">
                            <div class="DetailsContentContainer" style="background-color:#FDFDFD ;height: 230px; min-height: 100px; border-bottom: none;">
                                <div style="padding: 20px">
                                    <asp:TextBox ID="txtCmmts" runat="server" Width="605" Height="180" TextMode="MultiLine" />
                                </div>
                            </div>
                            <div class="DetailsContentContainer" style="background-color: #F7F7F7; min-height: 33px; padding-left: 25px;">
                                <table cellpadding="2" cellspacing="2" border="0">
                                    <tr>
                                        <td>
                                            <telerik:RadButton ID="btnUpdate" runat="server" OnClientClicking="updateCmmts" EnableViewState="false"
                                                OnClick="btnUpdate_Click" UseSubmitBehavior="true">
                                                <Icon SecondaryIconCssClass="rbOk" SecondaryIconRight="4" SecondaryIconTop="4" />
                                            </telerik:RadButton>
                                        </td>
                                        <td>
                                            <telerik:RadButton ID="btnCancel" runat="server" Style="display: none" OnClientClicking="cancelCmmts"
                                                UseSubmitBehavior="false" EnableViewState="false" CausesValidation="false">
                                                <Icon SecondaryIconCssClass="rbCancel" SecondaryIconRight="4" SecondaryIconTop="4" />
                                            </telerik:RadButton>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </telerik:RadPageView>
                    </telerik:RadMultiPage>
                </asp:Panel>
                <div class="noselectedbox" id="pnlNoRecord" enableviewstate="false" runat="server">
                    <div class="noselectedrecord" id="lblNoRecord" enableviewstate="false" runat="server">
                    </div>
                </div>
            </asp:Panel>
        </div>
    </div>
    <script src="TableSort.js" type='text/javascript' language='javascript'></script>
</asp:Content>
<asp:Content ID="cnt3" ContentPlaceHolderID="script" runat="Server">
</asp:Content>
