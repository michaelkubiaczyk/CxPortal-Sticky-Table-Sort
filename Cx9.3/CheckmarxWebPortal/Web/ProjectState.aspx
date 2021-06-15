<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/MainMaster.master" CodeBehind="ProjectState.aspx.cs" Inherits="CxWebClientApp.ProjectState" %>

<%@ Register TagPrefix="CX" Assembly="CxWebClientApp" Namespace="CxControls" %>


<asp:Content ID="cnt1" ContentPlaceHolderID="head" runat="Server">
    <script src="TableSort.js" type='text/javascript' language='javascript'></script>
    <script language="javascript" type="text/javascript">
        var toolbarBtn = null;

        function onClientButtonClicking(sender, args) {
            toolbarBtn = args.get_item();
        }

        function openReport(i_Type, i_ScanID, i_ProjectID, i_ScanDate) {
            if (i_Type != "VIEWER") {
                var win = radopenExt("GenerateScanReportNew.aspx?scanid=" + i_ScanID + "&projectid=" + i_ProjectID + "&ProjectName=" + encodeURIComponent(i_ScanDate.replace("'", "%27")));
                win.set_visibleTitlebar(false);
                win.set_modal(true);
                win.setSize(1000, 720);
                win.center();
            }
            else {
                window.open("ViewerMain.aspx?scanId=" + i_ScanID + "&ProjectID=" + i_ProjectID);
            }
        }

        function go2results(pid, sid) {
            location.href = 'ProjectScans.aspx?id=' + pid + '&sid=' + sid;
            return false;
        }

    </script>
</asp:Content>
<asp:Content ID="cnt2" ContentPlaceHolderID="cpmain" runat="Server">
    <script type="text/javascript">
        function onRequestStart(sender, args) {
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
            <telerik:AjaxSetting AjaxControlID="ProjectStateGrid">
                <UpdatedControls>
                    <telerik:AjaxUpdatedControl ControlID="ProjectStateGrid" />
                </UpdatedControls>
            </telerik:AjaxSetting>
        </AjaxSettings>
    </telerik:RadAjaxManager>
    <div class="box">     
        <div class="box-content" style="min-height: 400px; padding-right: 2px;">
            <CX:CxGrid ID="ProjectStateGrid" runat="server" ShowGroupPanel="true" AllowSorting="True"
                ExportHiddenColumnsList="Actions" MultiSelectionCheckboxes="false"
                AllowPaging="true" AllowCustomPaging="true" PagerStyle-AlwaysVisible="true" VirtualItemCount="1000"
                AllowFilteringByColumn="True" EnableViewState="true" EnableLinqExpressions="false">
                <MasterTableView AutoGenerateColumns="false" DataKeyNames="ProjectID" ClientDataKeyNames="ProjectID"
                    GroupLoadMode="Client" ShowHeadersWhenNoRecords="true" EnableNoRecordsTemplate="true"
                    AllowAutomaticInserts="false">
                    <Columns>
                        <%--  Project Name --%>
                       <telerik:GridTemplateColumn DataField="ProjectName" UniqueName="ProjectName" SortExpression="ProjectName" >
                                <ItemTemplate>
                                    <code ng-non-bindable>
                                        <a style="text-decoration:underline !important;" title="<%# HttpUtility.HtmlEncode(DataBinder.Eval(Container.DataItem, "ProjectName").ToString())%>" 
                                            href="portal#/projectState/<%#DataBinder.Eval(Container.DataItem, "ProjectID")%>/Summary"><%# HttpUtility.HtmlEncode(DataBinder.Eval(Container.DataItem, "ProjectName").ToString())%></a>
                                       
                                    </code>
                                </ItemTemplate>
                               </telerik:GridTemplateColumn>
                        <%-- Last Scan Date --%>
                        <telerik:GridDateTimeColumn DataField="LastScanDate" UniqueName="LastScanDate" SortExpression="LastScanDate"
                            AllowFiltering="true" DataType="System.DateTime" AutoPostBackOnFilter="true"
                            CurrentFilterFunction="GreaterThanOrEqualTo">
                        </telerik:GridDateTimeColumn>
                        <%-- Team Name --%>
                        <telerik:GridTemplateColumn DataField="Team" UniqueName="Team" SortExpression="Team"
                            AllowFiltering="true" AutoPostBackOnFilter="true" CurrentFilterFunction="Contains">
                            <ItemTemplate>
                                <code ng-non-bindable>
                                    <%#this.EncodeCurrentField(DataBinder.Eval(Container.DataItem, "Team").ToString())%>
                                </code>
                            </ItemTemplate>
                        </telerik:GridTemplateColumn>
                        <%-- Success Rate --%>
                        <telerik:GridNumericColumn DataField="SuccessRate" UniqueName="SuccessRate" SortExpression="SuccessRate"
                            AllowFiltering="true" AutoPostBackOnFilter="true" CurrentFilterFunction="NoFilter" DataType="System.Int32">
                        </telerik:GridNumericColumn>
                        <%-- LOC --%>
                        <telerik:GridNumericColumn DataField="LOC" UniqueName="LOC" SortExpression="LOC"
                            AllowFiltering="true" AutoPostBackOnFilter="true" CurrentFilterFunction="EqualTo" DataType="System.Int32">
                        </telerik:GridNumericColumn>
                        <%-- Risk Level Score --%>
                        <telerik:GridTemplateColumn DataField="RiskLevelScore" HeaderStyle-Width="170px"
                            UniqueName="RiskLevelScore" SortExpression="RiskLevelScore" AllowFiltering="true"
                            AutoPostBackOnFilter="true" CurrentFilterFunction="NoFilter" DataType="System.Int32"
                            GroupByExpression="RiskLevelScore Group By RiskLevelScore">
                            <ItemStyle VerticalAlign="Middle" HorizontalAlign="Center" />
                            <ItemTemplate>
                                <div id="divScanRisk" runat="server" enableviewstate="false" />
                                <span id="spnScanRisk" runat="server" enableviewstate="false" style="padding-top: 5px; min-width: 20px; text-align: left" />
                            </ItemTemplate>
                        </telerik:GridTemplateColumn>
                        <%-- High Vulnerabilities --%>
                        <telerik:GridNumericColumn DataField="HighVulnerabilities" UniqueName="HighVulnerabilities" SortExpression="HighVulnerabilities"
                            AllowFiltering="true" AutoPostBackOnFilter="true" CurrentFilterFunction="EqualTo" DataType="System.Int32">
                        </telerik:GridNumericColumn>
                        <%-- Medium Vulnerabilities --%>
                        <telerik:GridNumericColumn DataField="MediumVulnerabilities" UniqueName="MediumVulnerabilities" SortExpression="MediumVulnerabilities"
                            AllowFiltering="true" AutoPostBackOnFilter="true" CurrentFilterFunction="EqualTo" DataType="System.Int32">
                        </telerik:GridNumericColumn>
                        
                        <%-- Hidden Columns Start --%>

                        <%-- Low Vulnerabilities --%>
                        <telerik:GridNumericColumn DataField="LowVulnerabilities" Display="false" UniqueName="LowVulnerabilities" SortExpression="LowVulnerabilities"
                            AllowFiltering="true" AutoPostBackOnFilter="true" CurrentFilterFunction="EqualTo" DataType="System.Int32">
                        </telerik:GridNumericColumn>
                        <%-- Info --%>
                        <telerik:GridNumericColumn DataField="InfoVulnerabilities" Display="false" UniqueName="InfoVulnerabilities" SortExpression="InfoVulnerabilities"
                            AllowFiltering="true" AutoPostBackOnFilter="true" CurrentFilterFunction="EqualTo" DataType="System.Int32">
                        </telerik:GridNumericColumn>
                        <%-- Total results --%>
                        <telerik:GridNumericColumn DataField="TotalVulnerabilities" Display="false" UniqueName="TotalVulnerabilities" SortExpression="TotalVulnerabilities"
                            AllowFiltering="true" AutoPostBackOnFilter="true" CurrentFilterFunction="EqualTo" DataType="System.Int32">
                        </telerik:GridNumericColumn>
                        <%-- Statistics Calculation Date --%>
                        <telerik:GridDateTimeColumn DataField="StatisticsCalculationDate" Display="false" UniqueName="StatisticsCalcDate" SortExpression="StatisticsCalculationDate"
                            AllowFiltering="true" DataType="System.DateTime" AutoPostBackOnFilter="true"
                            CurrentFilterFunction="GreaterThanOrEqualTo">
                        </telerik:GridDateTimeColumn>
                        <%--  Queue Time --%>
                        <telerik:GridTemplateColumn DataField="QueueTime" Display="false" UniqueName="QueueTime" SortExpression="QueueTime"
                            AllowFiltering="false" AutoPostBackOnFilter="true" CurrentFilterFunction="Contains" DataType="System.TimeSpan">
                            <ItemTemplate>
                                <%#CxUtils.Instance.FormatTimeSpan(((TimeSpan)DataBinder.Eval(Container.DataItem, "QueueTime")))%>
                            </ItemTemplate>
                        </telerik:GridTemplateColumn>
                        <%-- Scan Time --%>
                        <telerik:GridTemplateColumn DataField="ScanTime" Display="false" UniqueName="ScanTime" SortExpression="ScanTime"
                            AllowFiltering="false" AutoPostBackOnFilter="true" CurrentFilterFunction="Contains" DataType="System.TimeSpan">
                            <ItemTemplate>
                                <%#CxUtils.Instance.FormatTimeSpan(((TimeSpan)DataBinder.Eval(Container.DataItem, "ScanTime")))%>
                            </ItemTemplate>
                        </telerik:GridTemplateColumn>

                        <%-- Hidden Columns End --%>

                        <%-- Actions --%>
                        <telerik:GridTemplateColumn UniqueName="Actions" Groupable="False" AllowFiltering="false">
                            <ItemTemplate>
                                <div id="divActions" runat="server" style="margin-top:3px;vertical-align: middle; cursor: pointer;">
                                    <img id="imgViewer" Visible='<%# PortalUser.IsAllowedToViewResults %>' runat="server" enableviewstate="false" alt="" src="images/ico/Search.png" />&nbsp;
                                    <img id="imgReports" runat="server" enableviewstate="false" alt="" src="images/icons/reports16x16.png" Visible='<%# (this.Page as CxPortalPage).PortalUser.IsAllowedToGenerateScanReport %>' />&nbsp; 
                                       
                                  <CX:CxLogsDownloadButton ID="lbScanLogs" runat="server" StreamLogData-ScanType="Finished" Visible='<%# (this.Page as CxPortalPage).PortalUser.IsAllowed2ManageSystemSettings || (this.Page as CxPortalPage).PortalUser.IsAllowedToDownloadScanLog %>' StreamLogData-Id='<%# (long)DataBinder.Eval(Container.DataItem, "LastScanID") %>' StreamLogData-ProjectName='<%# HttpUtility.UrlEncode(DataBinder.Eval(Container.DataItem, "ProjectName").ToString()) %>' StreamLogData-ScanTime='<%# DataBinder.Eval(Container.DataItem, "LastScanDate") %>'>
                                  </CX:CxLogsDownloadButton>

                                </div>
                            </ItemTemplate>
                            <HeaderStyle Width="100px"></HeaderStyle>
                        </telerik:GridTemplateColumn>
                    </Columns>
                    <SortExpressions>
                        <telerik:GridSortExpression FieldName="LastScanDate" SortOrder="Descending" />
                    </SortExpressions>
                </MasterTableView>
                <ClientSettings ReorderColumnsOnClient="True" AllowDragToGroup="True" AllowColumnsReorder="True"
                    AllowGroupExpandCollapse="true">
                    <Resizing AllowRowResize="false" AllowColumnResize="True" EnableRealTimeResize="True"
                        ResizeGridOnColumnResize="False"></Resizing>
                    <Selecting AllowRowSelect="true" />
                    <ClientEvents OnMasterTableViewCreated="MTVCreated" />                    
                    <ClientEvents OnCommand="GridCommand" />
                </ClientSettings>
                <GroupingSettings ShowUnGroupButton="true" />
                <PagerStyle AlwaysVisible="True" Mode="NextPrevAndNumeric" />
                <ExportSettings Pdf-PaperSize="A4" Pdf-PageTitle="ProjectState" Pdf-PageHeight="210mm" Pdf-PageWidth="297mm" FileName="ProjectState">
                </ExportSettings>
            </CX:CxGrid>
        </div>
    </div>
</asp:Content>
