<%@ Page Title="" Language="C#" MasterPageFile="~/MainMaster.master" AutoEventWireup="true" Inherits="UserQueueNew" Codebehind="UserQueue.aspx.cs" %>

<%@ Register TagPrefix="CX" Assembly="CxWebClientApp" Namespace="CxControls" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <style type="text/css">
        .DetailsContentContainer div {
            font-family: "segoe ui", arial, sans-serif;
            font-size: 12px;
        }

        .label {
            min-width: 160px;
            float: left;
        }

        .separator {
            height: 10px;
            clear: both;
        }

        .progressbar {
            margin: auto;
            width: 300px;
            border: 1px solid green;
            height: 22px;
        }

        .slider {
            height: 22px;
            background-image: url("Images/Common/Slider.gif");
        }

        .slidertext {
            padding-top: 3px;
            width: 300px;
            text-align: center;
            color: Black;
            font-weight: bold;
        }

        .partialresult td {
            padding: 2px 5px 2px 0px;
            white-space: nowrap;
        }

        .partialresult .td1 {
            width: 16px;
        }

        .partialresult .td2 {
            width: 200px;
        }

        .actionbutton {
            width: 20px;
            display: inline-block;
        }

        #<%=dtStageDetails.ClientID%> {
            width: 300px;
            overflow: hidden;
        }

        .scan-queue-state-icon{
            vertical-align:middle;
        }
    </style>

    <script type="text/javascript">
        var DELETE_SCAN_CONFIRMATION_MESSAGE = "<%=this.GetTermFromResourceJSEncoded("DELETE_SCAN_CONFIRMATION_MESSAGE")%>";
        var DELETE_SCAN_WITH_PARTIAL_RESULTS_CONFIRMATION_MESSAGE = "<%=this.GetTermFromResourceJSEncoded("DELETE_SCAN_WITH_PARTIAL_RESULTS_CONFIRMATION_MESSAGE")%>";
        var POSTPONE_SCAN_CONFIRMATION_MESSAGE = "<%=this.GetTermFromResourceJSEncoded("POSTPONE_SCAN_CONFIRMATION_MESSAGE")%>";
        
        function onRequestStart(sender, args) {
            if (args.get_eventTarget().indexOf("_GridToolbar") >= 0) {
                if (toolbarBtn.get_value() != "REFRESH") {
                    args.set_enableAjax(false);
                }
            }
        }

        function onResponseEnd(sender, args) {
            if(args.get_eventTarget()=='<%=QueueGrid.UniqueID%>'){
                if(args.get_eventArgument().indexOf('RebindGrid')>=0){
                            setTimeout(function(){$find("<%=QueueGrid.ClientID%>").get_masterTableView().rebind(); } , <%=CxPortalSettings.Default.ProgressBarInterval%>);
                }
            }
        }

        var toolbarBtn = null;

        function onClientButtonClicking(sender, args) {
            toolbarBtn = args.get_item();
        }
        function ConfirmWindow(i_PR, i_Event) {
            var msg = i_PR ? DELETE_SCAN_WITH_PARTIAL_RESULTS_CONFIRMATION_MESSAGE : DELETE_SCAN_CONFIRMATION_MESSAGE;
            var e = $telerik.$.event.fix(i_Event || window.event);
            openConfirm(msg, i_Event, function(args) {
                $get('<%=hdnDeleteAnswer.ClientID%>').value = !args.value;
                eval($telerik.$(e.currentTarget ? e.currentTarget : e.srcElement.parentNode).attr('href'));
            }, i_PR);
        }
        function ConfirmPostponeWindow(i_Msg, i_Event) {
            var e = $telerik.$.event.fix(i_Event || window.event);
            openConfirm(i_Msg, i_Event, function() {
                eval($telerik.$(e.currentTarget ? e.currentTarget : e.srcElement.parentNode).attr('href'));
            });
        }
        
        
        function go2results(pid, sid) {
            location.href = 'ProjectScans.aspx?id='+pid+'&sid='+sid;
            return false;
        }              
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cpmain" runat="Server">
    <telerik:RadAjaxLoadingPanel ID="PageLoadingPanel" runat="server" Skin="Silk">
    </telerik:RadAjaxLoadingPanel>
    <telerik:RadAjaxManager ID="PageAjaxManager" runat="server" DefaultLoadingPanelID="PageLoadingPanel"
        ClientEvents-OnRequestStart="onRequestStart" ClientEvents-OnResponseEnd="onResponseEnd">
        <AjaxSettings>
            <telerik:AjaxSetting AjaxControlID="QueueGrid">
                <UpdatedControls>
                    <telerik:AjaxUpdatedControl ControlID="QueueGrid" />
                    <telerik:AjaxUpdatedControl ControlID="pnlWrapper" />
                </UpdatedControls>
            </telerik:AjaxSetting>
        </AjaxSettings>
    </telerik:RadAjaxManager>
    <div class="box">
        
        <div class="box-content" style="min-height: 600px; padding: 2px;">
            <CX:CxGrid ID="QueueGrid" runat="server" ExportHiddenColumnsList="Actions,StatusAsHTML" ExportVisibleColumnsList="Status" EnableLinqExpressions=false>
                <MasterTableView AutoGenerateColumns="false" DataKeyNames="RunID,ScanID">
                    <Columns>
                        <telerik:GridTemplateColumn DataField="IsIncremental" UniqueName="IsIncremental"
                            HeaderStyle-Width="30">
                            <ItemStyle VerticalAlign="Middle" HorizontalAlign="Center" />
                            <ItemTemplate>
                                <img alt="inc" src="Images/Icons/<%#CxScansScreenDataHelper.GetScanQueueScopeIcon((bool)DataBinder.Eval(Container.DataItem, "IsIncremental"))%>"
                                    title="<%#(bool)DataBinder.Eval(Container.DataItem, "IsIncremental") ? GetTermFromResource("INCREMENTAL_SCAN") :  GetTermFromResource("FULL_SCAN") %>" 
                                    class="scan-queue-state-icon"/>
                            </ItemTemplate>
                        </telerik:GridTemplateColumn>
                        <telerik:GridBoundColumn DataField="QueuePosition" UniqueName="QueuePosition" SortExpression="QueuePosition"
                            HeaderStyle-Width="50">
                        </telerik:GridBoundColumn>
                        <telerik:GridDateTimeColumn DataField="TimeScheduled" UniqueName="TimeScheduled"
                            SortExpression="TimeScheduled" HeaderStyle-Width="150" DataType="System.DateTime" CurrentFilterFunction="EqualTo">
                        </telerik:GridDateTimeColumn>
                        <telerik:GridBoundColumn DataField="InitiatorName" UniqueName="InitiatorName" SortExpression="InitiatorName">
                        </telerik:GridBoundColumn>
                          <telerik:GridBoundColumn DataField="Origin" UniqueName="Origin" SortExpression="Origin">
                        </telerik:GridBoundColumn>
                        <telerik:GridTemplateColumn DataField="ProjectName" UniqueName="ProjectName" SortExpression="ProjectName" >
                                <ItemTemplate>
                                    <code ng-non-bindable>
                                       <%#this.BuildProjectNameCell(DataBinder.Eval(Container.DataItem, "ProjectName").ToString())%>
                                    </code>
                                </ItemTemplate>
                               </telerik:GridTemplateColumn>
                        <telerik:GridBoundColumn DataField="ServerName" UniqueName="ServerName" SortExpression="ServerName">
                        </telerik:GridBoundColumn>
                        <telerik:GridBoundColumn DataField="LOCString" UniqueName="LOCString" HeaderStyle-Width="100px"
                            SortExpression="LOC">
                        </telerik:GridBoundColumn>  
                        <telerik:GridBoundColumn DataField="Status" UniqueName="Status" Visible="false" HeaderText="Status">
                        </telerik:GridBoundColumn>                       
                        <telerik:GridTemplateColumn DataField="StatusAsHTML" UniqueName="StatusAsHTML" GroupByExpression="StatusAsString GROUP BY StatusAsString"
                            SortExpression="StatusAsInt" HeaderStyle-Width="160px">
                            <ItemTemplate>
                                <img id="Img1" alt="" title='<%#GetTermFromResource("PARTIAL_SCAN_RESULTS")%>'
                                 runat="server" 
                                 src="images/ico/Search.png"
                                 visible='<%# Eval("PartialResult") %>' 
                                  style="float:left;padding:3px 18px 0px 0px" />
                                <%# Eval("StatusAsHTML")%>
                                <img id="ImgInfo" alt=""
                                 runat="server"
                                 src="images/icons/information16x16.png"
                                 visible='<%# Eval("TooltipVisible")%>' 
                                 style="vertical-align: text-bottom;"/>
                                <telerik:RadToolTip runat="server" ID="rttStatus" RelativeTo="Element" TargetControlID="ImgInfo">
                                    <%# Eval("StageMessage") %>
                                </telerik:RadToolTip>
                            </ItemTemplate>
                        </telerik:GridTemplateColumn>
                        <telerik:GridTemplateColumn HeaderStyle-Width="100px" Groupable="False" UniqueName="Actions"
                            AllowFiltering="false" ShowSortIcon="false" ItemStyle-CssClass="actionbuttons" HeaderStyle-CssClass="actionbuttons">
                            <ItemTemplate>
                                <div class="actionbutton" >
                                    <asp:LinkButton ID="btnPostpone" CommandName="PostponeScan" runat="server" ToolTip='<%#GetTermFromResource("POSTPONE")%>'
                                        Visible='<%# Eval("PostpondVisible") %>' OnClientClick="return ConfirmPostponeWindow(POSTPONE_SCAN_CONFIRMATION_MESSAGE, event)">
                                  <img alt="<%#GetTermFromResource("POSTPONE")%>" style ="margin-bottom:-3px;"  src="Images/Icons/Arrow.png"  />
                                    </asp:LinkButton>
                                </div>
                                <div class="actionbutton" style ="margin-bottom:-3px;">
                                    <asp:LinkButton ID="btnDelete" CssClass="actionbutton" CommandName="Delete" runat="server"
                                        Visible='<%# Eval("DeleteVisible") %>' OnClientClick='<%# string.Format("return ConfirmWindow({0:true;0;false}, event);",Eval("PartialResult").GetHashCode()) %>'
                                        ToolTip='<%#GetTermFromResource("DELETE")%>'>
                                    <img alt="<%#GetTermFromResource("DELETE")%>" style ="margin-bottom:-3px;" src="Images/Icons/delete.png" />
                                    </asp:LinkButton>
                                </div>
                                <div class="actionbutton" style ="margin-bottom:-3px;">
                                    <asp:LinkButton ID="btnGo2Results" CssClass="actionbutton" CommandName="Delete" runat="server"
                                        Visible='<%# Eval("ResultsVisible") %>' OnClientClick='<%# string.Format("return go2results({0},{1})",Eval("ProjectID"),Eval("ScanID"))   %>'
                                        ToolTip='<%#GetTermFromResource("RESULTS")%>'>
                                    <img alt="<%#GetTermFromResource("RESULTS")%>" style ="height:16px;margin-bottom:-3px;" src="Images/Icons/Document.png" />
                                    </asp:LinkButton>
                                </div>
                                <div class="actionbutton" style ="margin-bottom:-3px;">
                                    <Cx:CxLogsDownloadButton id="lbScanLogs" MarginBottom="-5px" runat="server" StreamLogData-ScanType="UnFinished" Visible='<%# (this.Page as CxPortalPage).PortalUser.IsScanner && IsScanFinished((CxWebClientApp.CxWebServices.CurrentStatusEnum)DataBinder.Eval(Container.DataItem, "Status"))  %>' StreamLogData-Id='<%# long.Parse((string)DataBinder.Eval(Container.DataItem, "RunID")) %>' StreamLogData-ProjectName='<%# HttpUtility.UrlEncode(DataBinder.Eval(Container.DataItem, "ProjectName").ToString()) %>' StreamLogData-ScanTime='<%# DataBinder.Eval(Container.DataItem, "TimeScheduled") %>'>
                                    </Cx:CxLogsDownloadButton>
                                </div>
                            </ItemTemplate>
                        </telerik:GridTemplateColumn>
                    </Columns>
                    <SortExpressions> 
                        <telerik:GridSortExpression FieldName="QueuePosition" SortOrder="Ascending" />
                        <telerik:GridSortExpression FieldName="TimeScheduled" SortOrder="Descending" />
                     </SortExpressions>
                    <PagerStyle AlwaysVisible="True"></PagerStyle>
                </MasterTableView>
                <ClientSettings ReorderColumnsOnClient="True" AllowDragToGroup="True" AllowColumnsReorder="True"
                    AllowGroupExpandCollapse="true" EnablePostBackOnRowClick="true">
                    <Resizing AllowRowResize="false" AllowColumnResize="True" EnableRealTimeResize="True"
                        ResizeGridOnColumnResize="False"></Resizing>
                    <Selecting AllowRowSelect="true" />
                    <ClientEvents OnRowSelected="ScanRowSelected"></ClientEvents>
                </ClientSettings>
                 <ExportSettings Pdf-PaperSize="A4" Pdf-PageTitle="Queue" Pdf-PageHeight="210mm" Pdf-PageWidth="297mm" FileName="Queue">
                </ExportSettings>
                
                <GroupingSettings ShowUnGroupButton="true" />
                <PagerStyle AlwaysVisible="True" Mode="Slider" />
                <SelectedItemStyle BorderStyle="Solid" />
            </CX:CxGrid>
            <br />
            <asp:Panel ID="pnlWrapper" runat="server" style="background-color:#FDFDFD;" >
                <asp:HiddenField runat="server" ID="hdnDeleteAnswer"  />
                <asp:HiddenField ID="hdnSelectedScan" EnableViewState="false" runat="server" />
                <div id="pnlQueueDetails" runat="server" class="DetailsContentContainer" style="padding: 10px;">
                    <div style="float: left; width: 300px;">
                        <div id="lblPosition" class="label" runat="server">
                        </div>
                        <div id="dtPosition" runat="server">
                        </div>
                        <div class="separator">
                        </div>
                        <div id="lblQueueDate" class="label" runat="server">
                        </div>
                        <div id="dtQueueDate" runat="server">
                        </div>
                        <div class="separator">
                        </div>
                        <div id="lblOwner" class="label" runat="server">
                        </div>
                        <div id="dtOwner" runat="server">
                        </div>
                        <div class="separator" ></div>
                        <div id="lblStatus" class="label" runat="server">
                        </div>
                        <div id="dtStatus" runat="server">
                        </div>
                        <div class="separator">
                        </div>
                        <div class="progressbar" id="divTotalProgress" runat="server">
                            <div id="divTotalProgressInner" runat="server" class="slider">
                                &nbsp;</div>
                        </div>
                        <div class="separator">
                        </div>
                        <div class="progressbar"  id="divStageProgress" runat="server">
                            <div id="divStageProgressInner" class="slider" runat="server">
                                &nbsp;</div>
                        </div>
                        <div class="separator">
                        </div>
                         <div id="dtStageDetails" runat="server">
                        </div>
                        
                    </div>
                    <div id="lblPartialResults" class="label" runat="server" style="padding-bottom: 3px; margin-left: 10px;"></div>
                    <div id="divPartialResultsTableContainer" style="float: left; overflow:auto; height:250px; margin-left: 10px; padding-right: 20px; padding-right: 0 \ ; ">
                        <table id="tblpartial" runat="server" cellpadding="0" cellspacing="2" class="partialresult" >
                        </table>
                    </div>
                </div>
                <div class="noselectedbox" id="pnlNoRecord" enableviewstate="false" runat="server">
                    <div class="noselectedrecord" id="lblNoRecord" enableviewstate="false" runat="server">
                    </div>
                </div>
            </asp:Panel>
        </div>
    </div>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="script" runat="Server">
    <script type="text/jscript" language="javascript">
        function fixElementBounds(elementName) {
            var element = $telerik.$('#' + elementName);
            var elementParent = element.parent();
            if (element.length != 0 && elementParent.length != 0) {
                element.width('auto');
                if (element.offset().left + element.outerWidth() > elementParent.width()) {
                    element.width(elementParent.width() - element.offset().left - (element.outerWidth() - element.width()));
                }
            }
        }
        function fixPartialResultsTableContainerBounds() {
            fixElementBounds("divPartialResultsTableContainer");
        }
        $telerik.$(window).resize(fixPartialResultsTableContainerBounds);

        $telerik.$(document).ready(function() {
            setTimeout(function() { $find("<%=QueueGrid.ClientID%>").get_masterTableView().rebind(); }, <%=CxPortalSettings.Default.ProgressBarInterval%>);
        });
        function ScanRowSelected(sender, eventArg) {
            var selectedScan = eventArg.getDataKeyValue("RunID");
            $get("<%=hdnSelectedScan.ClientID%>").value = selectedScan;
        }
    </script>
</asp:Content>
