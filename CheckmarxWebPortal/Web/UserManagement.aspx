<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/MainMaster.master" Inherits="UserManagement" CodeBehind="UserManagement.aspx.cs" %>

<%@ Register TagPrefix="CX" Assembly="CxWebClientApp" Namespace="CxControls" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <%= System.Web.Optimization.Styles.Render("~/Css/userManagement") %>
    <script type="text/javascript">
        var DELETE_USER_CONFIRMATION_MESSAGE = '<%=this.GetTermFromResourceJSEncoded("DELETE_USER_CONFIRMATION_MESSAGE")%>';
        var disableTree = 0;

        function openAddUserWindow() {
            var wnd = radopen("popCreateUser.aspx", null);
            wnd.SetSize(598, 710);
            wnd.Center();
            wnd.add_close(openAddUserWindowClosed);
        }

        function openAddUserWindowClosed(wnd, args) {
            var arg = args.get_argument();
            if (arg) {
                if (!arg.canceled) {
                    $find("<%=UsersGrid.ClientID%>").get_masterTableView().rebind();
                }
            }
        }

        function RowSelected(sender, eventArg) {
            var selectedUserID = eventArg.getDataKeyValue("ID");
            $get("<%=hdnSelUserID.ClientID%>").value = selectedUserID
            $telerik.$('#<%=btnUserDetail.ClientID%>').trigger('click');

        }

        function RefreshGrid() {
            $find("<%=UsersGrid.ClientID%>").get_masterTableView().rebind();
        }

        function ConfirmWindow(i_Msg, i_Event) {
            var e = $telerik.$.event.fix(i_Event || window.event);
            openConfirm(i_Msg, i_Event, function () { eval($telerik.$(e.currentTarget ? e.currentTarget : e.srcElement.parentNode).attr('href')); });

        }

        function LicenseNotAvailWin(i_Msg) {
            openInfo(i_Msg);
        }

        function treeNodeClicked(sender, eventArgs) {
            eventArgs.get_node().unselect();
        }

        function nodeCheck(sender, eventArgs) {
            $telerik.$("#<%=expirationDateDivLabel.ClientID%>").hide();
            $telerik.$("#ctl00_cpmain_radExpDate_wrapper").show();
            var node = eventArgs.get_node();


            if (node.get_attributes().getAttribute('<%=k_TreeNodeTypeAttribute%>') == "Team") {
                var parentCompany = findParentNodeByAttribute(node, '<%=k_TreeNodeTypeAttribute%>', 'Company');
                var companyTeams = findChildNodesByAttribute(parentCompany, '<%=k_TreeNodeTypeAttribute%>', 'Team');
                unCheckAll(companyTeams);

                if (!node.get_checked()) {
                    var tree = $find("<%=groupsTree.ClientID%>");
                    var nodes = tree._getAllItems();
                    var chekednodes = 0;
                    for (var i = 0; i < nodes.length; i++) {
                        if (nodes[i].get_checked()) {
                            chekednodes++;
                        }
                    }

                    if (chekednodes == 0) {
                        node.set_checked(true);
                    }
                }
                else {
                    uncheckParent(node);
                    unCheckChilds(node);
                }
            }
            else {
                unCheckAll();
                node.set_checked(true);
                if (node.get_attributes().getAttribute('<%=k_TreeNodeTypeAttribute%>') == "Server") {
                    $telerik.$("#<%=expirationDateDivLabel.ClientID%>").show();
                    $telerik.$("#ctl00_cpmain_radExpDate_wrapper").hide();
                }
            }


            rebidRoles(node.get_attributes().getAttribute('<%=k_TreeNodeTypeAttribute%>'), true);
        }

        function findParentNodeByAttribute(node, attributeName, attributeValue) {
            var parent = node.get_parent();
            while (parent && parent.get_attributes().getAttribute(attributeName) !== attributeValue) {
                parent = parent.get_parent();
            }
            return parent || null;
        }

        function findChildNodesByAttribute(node, attributeName, attributeValue) {
            var result = [];
            for (var i = 0; i < node.get_nodes().get_count() ; i++) {
                var childNode = node.get_nodes().getNode(i);
                if (childNode.get_attributes().getAttribute(attributeName) === attributeValue) {
                    result.push(childNode);
                    var childNodes = findChildNodesByAttribute(childNode, attributeName, attributeValue);
                    for (var j = 0; j < childNodes.length; j++) {
                        result.push(childNodes[j]);
                    }
                }
            }
            return result;
        }

        function rebidRoles(i_Type, i_SelectDefault) {
            var combo = $find('<%=ddlRole.ClientID %>');
            combo.trackChanges();
            var items = combo.get_items();

            for (var i = 0; i < items.get_count() ; i++) {
                var item = items.getItem(i);

                if (item.get_value() == "0" || item.get_value() == "1") {
                    if (i_Type != "Team") {
                        item.disable();
                    }
                    else {
                        item.enable();
                    }
                }

                if (item.get_value() == "2" || item.get_value() == "3") {
                    if (i_Type != "Company") {
                        item.disable();
                    }
                    else {
                        item.enable();
                    }
                }

                if (item.get_value() == "5" || item.get_value() == "6") {
                    if (i_Type != "Server") {
                        item.disable();
                    }
                    else {
                        item.enable();
                    }
                }

                if (item.get_value() == "4") {
                    if (i_Type != "SP") {
                        item.disable();
                    }
                    else {
                        item.enable();
                    }
                }
            }
            if (i_SelectDefault) {
                items.getItem(0).select();
            }
            combo.commitChanges();
        }




        function unCheckAll(nodesToSkip) {
            var tree = $find("<%=groupsTree.ClientID%>");
            var nodes = tree._getAllItems();
            for (var i = 0; i < nodes.length; i++) {
                if (!nodesToSkip || nodesToSkip.length == 0) {
                    nodes[i].set_checked(false);
                }
                else {
                    if (nodesToSkip.indexOf(nodes[i]) < 0) {
                        nodes[i].set_checked(false);
                    }
                }
            }
        }

        function CheckTeams(sender, eventArgs) {
            var tree = $find("<%=groupsTree.ClientID%>");
            var nodes = tree._getAllItems();
            for (var i = 0; i < nodes.length; i++) {
                if (nodes[i].get_checked()) {
                    eventArgs.IsValid = true;
                    return;
                }
            }
            eventArgs.IsValid = false;
        }

        function isMyParentChecked(i_Node) {
            if (i_Node.get_level() > 0) {
                if (i_Node.get_parent().get_checked()) {
                    return true
                }
                else {
                    return isMyParentChecked(i_Node.get_parent());
                }
            }
            else {
                return i_Node.get_checked();
            }
        }

        function uncheckParent(i_Node) {
            if (i_Node.get_level() > 0) {
                i_Node.get_parent().set_checked(false);
                uncheckParent(i_Node.get_parent());
            }
        }


        function unCheckChilds(i_Node) {
            if (i_Node == null) {
                return;
            }

            for (var i = 0; i < i_Node.get_nodes().get_count() ; i++) {
                i_Node.get_nodes().getNode(i).set_checked(false);
                unCheckChilds(i_Node.get_nodes().getNode(i));
            }
        }

        var toolbarBtn = null;

        function onClientButtonClicking(sender, args) {
            toolbarBtn = args.get_item();
            if (args.get_item().get_value() == "<%=k_AddUserValue%>") {
                args.set_cancel(true);
                openAddUserWindow();
            }
        }

        function onRequestStart(sender, args) {

            requestStart(sender, args);

            if (args.get_eventTarget().indexOf("_GridToolbar") >= 0) {
                if (toolbarBtn.get_value() != "REFRESH") {
                    args.set_enableAjax(false);
                }
            }
        }

        function updateClick(button, args) {
            if (button.get_id() == '<%=btnCancel.ClientID%>') {
                $find('<%=btnUpdate.ClientID%>').set_text('<%=this.GetTermFromResourceJSEncoded("EDIT")%>');
                $telerik.$("#<%=btnCancel.ClientID%>").hide();
                enableForm(false);

            }
            else {
                if (button.get_text() == '<%=this.GetTermFromResourceJSEncoded("EDIT")%>') {
                    button.set_text('<%=this.GetTermFromResourceJSEncoded("UPDATE")%>');
                    $telerik.$("#<%=btnCancel.ClientID%>").show();
                    enableForm(true);
                    Page_ClientValidate("dummy");
                    args.set_cancel(true);
                }
                else {
                    var isIPLimitEnabled = document.getElementById("<%=ipLimitEnable.ClientID%>").checked;

                    var isValid = Page_ClientValidate("_edit");
                    if (!isValid) {
                        args.set_cancel(true);
                    }
                    if (isIPLimitEnabled && isConfirmIPDialogRequired()) {
                        openConfirm("<%= this.GetTermFromResourceJSEncoded("CONFIRM_OTHER_IP_ADDRESSES") %>", window.event, function () {
                            eval(button._postBackReference);
                        });
                        args.set_cancel(true);
                    }
                }
            }
        }

        function isConfirmIPDialogRequired() {
            var isRequired = false;
            var selectedUserID = document.getElementById("<%= hdnSelUserID.ClientID %>").value;
            var currentUserID = "<%= PortalUser.UserID%>";
            if (currentUserID == selectedUserID) {
                var myIp = document.getElementById("hdnClientIP").value.trim();
                var firstIP = document.getElementById("<%= txtIPAddress1.ClientID %>").value.trim();
                var secondIP = document.getElementById("<%= txtIPAddress2.ClientID %>").value.trim();

                if (firstIP == secondIP == "") {
                    if (myIp != firstIP && myIp != secondIP) {
                        isRequired = true;
                    }
                }
            }
            return isRequired;
        }

        function enableForm(i_Enable) {
            if (i_Enable) {
                $telerik.$("#<%=txtCell.ClientID%>").removeAttr("disabled");
                $telerik.$("#<%=txtEmail.ClientID%>").removeAttr("disabled");
                $telerik.$("#<%=txtFirstName.ClientID%>").removeAttr("disabled");
                $telerik.$("#<%=txtLastName.ClientID%>").removeAttr("disabled");
                $telerik.$("#<%=txtJobTitle.ClientID%>").removeAttr("disabled");
                $telerik.$("#<%=txtPhone.ClientID%>").removeAttr("disabled");
                $telerik.$("#<%=ddlRole.ClientID%>").removeAttr("disabled");
                $telerik.$("#<%=ddlLanguage.ClientID%>").removeAttr("disabled");
                $telerik.$("#<%=txtJobTitle.ClientID%>").removeAttr("disabled");
                $telerik.$("#<%=txtPhone.ClientID%>").removeAttr("disabled");
                $telerik.$("#<%=txtAudit.ClientID%>").removeAttr("disabled");
                $telerik.$("#<%=txtSkype.ClientID%>").removeAttr("disabled");
                $telerik.$("#ctl00_cpmain_reviewer input").removeAttr("disabled");
                $telerik.$(".scanner input").removeAttr("disabled");
                if (!disableTree) {
                    $find("<%=groupsTree.ClientID%>").set_enabled(true);
                    enableTreeNodes();
                }
                $find("<%=radExpDate.ClientID%>").set_enabled(true);

                $find("<%=ddlRole.ClientID%>").enable(true);
                rebidRoles(getSelectedTeam(), false);


                $find("<%=ddlLanguage.ClientID%>").enable(true);
                $telerik.$("#<%=ipLimitEnable.ClientID%>").removeAttr("disabled");
                toggleEnableIPLimiters(i_Enable);
            }
            else {
                $telerik.$("#<%=txtCell.ClientID%>").attr("disabled", "disabled");
                $telerik.$("#<%=txtEmail.ClientID%>").attr("disabled", "disabled");
                $telerik.$("#<%=txtFirstName.ClientID%>").attr("disabled", "disabled");
                $telerik.$("#<%=txtLastName.ClientID%>").attr("disabled", "disabled");
                $telerik.$("#<%=txtJobTitle.ClientID%>").attr("disabled", "disabled");
                $telerik.$("#<%=txtPhone.ClientID%>").attr("disabled", "disabled");
                $telerik.$("#<%=ddlRole.ClientID%>").attr("disabled", "disabled");
                $telerik.$("#<%=ddlLanguage.ClientID%>").attr("disabled", "disabled");
                $telerik.$("#<%=txtAudit.ClientID%>").attr("disabled", "disabled");
                 $telerik.$("#<%=txtSkype.ClientID%>").attr("disabled", "disabled");
                $telerik.$("#ctl00_cpmain_reviewer input").attr("disabled", "disabled");
                $telerik.$(".scanner input").attr("disabled", "disabled");
                $find("<%=ddlRole.ClientID%>").disable();
                $telerik.$("#<%=txtJobTitle.ClientID%>").attr("disabled", "disabled");
                $telerik.$("#<%=txtPhone.ClientID%>").attr("disabled", "disabled");
                $find("<%=radExpDate.ClientID%>").set_enabled(false);
                $find("<%=groupsTree.ClientID%>").set_enabled(false);
                $find("<%=ddlLanguage.ClientID%>").disable(false);

                $telerik.$("#<%=ipLimitEnable.ClientID%>").attr("disabled", "disabled");
                toggleEnableIPLimiters(i_Enable);
            }
        }

        function toggleEnableIPLimiters(isFormEnabled) {

            var isIpLimiterEnabled = document.getElementById("<%=ipLimitEnable.ClientID%>").checked;
            var ipValidator1 = document.getElementById('<%= ipAddress1Validator.ClientID %>');
            var ipValidator2 = document.getElementById('<%= ipAddress2Validator.ClientID %>');

            if (isIpLimiterEnabled && isFormEnabled) {
                $telerik.$("#<%=txtIPAddress1.ClientID%>").removeAttr("disabled");
                $telerik.$("#<%=txtIPAddress2.ClientID%>").removeAttr("disabled");
                ValidatorEnable(ipValidator1, true);
                ValidatorEnable(ipValidator2, true);
            }
            else {
                $telerik.$("#<%=txtIPAddress1.ClientID%>").attr("disabled", "disabled");
                $telerik.$("#<%=txtIPAddress2.ClientID%>").attr("disabled", "disabled");
                ValidatorEnable(ipValidator1, false);
                ValidatorEnable(ipValidator2, false);
            }
        }

        function enableTreeNodes() {
            var allNodes = $find("<%=groupsTree.ClientID%>").get_allNodes();
            for (var i = 0; i < allNodes.length; i++) {
                allNodes[i].enable();
            }
            return false;
        }

        function getSelectedTeam() {
            var allNodes = $find("<%=groupsTree.ClientID%>").get_allNodes();
            for (var i = 0; i < allNodes.length; i++) {
                if (allNodes[i].get_checked()) {
                    return allNodes[i].get_attributes().getAttribute('<%=k_TreeNodeTypeAttribute%>');
                }
            }
            return false;
        }

        function initForm() {
            if ($find("<%=ddlRole.ClientID%>") != null && $find("<%=radExpDate.ClientID%>") != null && $find("<%=groupsTree.ClientID%>") != null) {
                enableForm(false);
                ensureVisibleTabSelected();
            }
            else {
                setTimeout(function () { initForm(); }, 100);
            }
        }

        function ensureVisibleTabSelected() {
            var tabstrip = $find('<%= UserTabStrip.ClientID %>');
            var tabs = tabstrip.get_tabs();
            if (tabs.get_count() == 1) {
                tabs.getTab("0").select();
            }
        }

        function roleChanged(sender, args) {
            var selectedItem = args.get_item();
            if (selectedItem.get_value() == '1') {
                $telerik.$('#ctl00_cpmain_reviewer').show();
            }
            else {
                $telerik.$('#ctl00_cpmain_reviewer').hide();
            }

            if (selectedItem.get_value() == '0') {
                $telerik.$('.scanner').show();
                $get("<%=chkChangeNotExploitable.ClientID%>").checked = true;
            }
            else {
                $telerik.$('.scanner').hide();
            }

        }



        function isUserEmailChanged(newEmail) {
            var hdnEmailReg = new RegExp($get('<%=hdnEmail.ClientID%>').value, "i");
            return !(hdnEmailReg.test(newEmail));
        }

        function isValidEmail(sender, args) {
            if (isUserEmailChanged(args.Value)) {
                $telerik.$.ajax({
                    type: 'POST',
                    async: false,
                    url: 'popCreateUser.aspx/isValidEmail',
                    data: '{\'i_Email\':\'' + args.Value + '\'}',
                    contentType: 'application/json; charset=utf-8',
                    dataType: 'json',
                    success: function (response) {
                        if (response.d != null) {
                            args.IsValid = response.d;
                            $get(sender.id).isvalid = response.d;
                            eval('$get(sender.id).style.visibility=' + (response.d ? '\'hidden\';' : '\'\';'));
                        }
                    }
                });
            }
            else {
                args.IsValid = true;
            }
        }

        function isAdminAllowedToChangeUserPassword(userID) {
            var result = null;
            $telerik.$.ajax({
                type: 'POST',
                async: false,
                url: 'UserManagement.aspx/IsAdminAllowedToChangeUserPassword',
                data: '{\'i_UserID\':' + userID + '}',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (response) {
                    if (response.d != null) {
                        result = response.d.IsAllowed;
                        if (!result) {
                            openInfo(response.d.Message, null);
                        }
                    }
                }
            });
            return result;
        }

        function CallOpenChangePassword(userID, userName) {
            if (isAdminAllowedToChangeUserPassword(userID)) {
                var i_Msg = '<%=this.GetTermFromResourceJSEncoded("YOU_ARE_ABOUT_TO_CHANGE_PASSWORD_TO")%> ' + userName;
                openConfirm(i_Msg, null, function () { OpenChangePasswordPopup(userID); });
            }
        }

        function OpenChangePasswordPopup(userID) {
            var wnd = radopen("popChangePassword.aspx?UserID=" + userID, null);
            wnd.SetSize(620, 220);
            wnd.Center();
        }

        function fixDisableDisappear(e) {
            e.updateCssClass();
        }
    </script>
    <style type="text/css">
        .chk span, div, input, label {
            vertical-align: middle;
        }

        .txtIPAddress{
            width: 210px !important;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cpmain" runat="Server">
    <!--telerik-->
    <telerik:RadAjaxLoadingPanel ID="PageLoadingPanel" runat="server" Skin="Silk">
    </telerik:RadAjaxLoadingPanel>
    <telerik:RadAjaxManager ID="PageAjaxManager" runat="server" DefaultLoadingPanelID="PageLoadingPanel"
        ClientEvents-OnRequestStart="onRequestStart">
        <AjaxSettings>
            <telerik:AjaxSetting AjaxControlID="UsersGrid">
                <UpdatedControls>
                    <telerik:AjaxUpdatedControl ControlID="UsersGrid" />
                    <telerik:AjaxUpdatedControl ControlID="pnlWrapper" />
                </UpdatedControls>
            </telerik:AjaxSetting>
            <telerik:AjaxSetting AjaxControlID="btnUserDetail">
                <UpdatedControls>
                    <telerik:AjaxUpdatedControl ControlID="pnlWrapper" />
                </UpdatedControls>
            </telerik:AjaxSetting>
            <telerik:AjaxSetting AjaxControlID="btnUpdate">
                <UpdatedControls>
                    <telerik:AjaxUpdatedControl ControlID="UsersGrid" />
                    <telerik:AjaxUpdatedControl ControlID="pnlWrapper" />
                </UpdatedControls>
            </telerik:AjaxSetting>
        </AjaxSettings>
    </telerik:RadAjaxManager>
    <!--telerik-->
    <!-- box -->
    <div class="box">

        <div class="box-content" style="min-height: 600px; padding-right: 2px">
            <CX:CxGrid ID="UsersGrid" runat="server" ShowGroupPanel="true" AllowSorting="True"
                AllowPaging="True" AllowFilteringByColumn="True" ExportHiddenColumnsList="Action"
                EnableLinqExpressions="false" Width="100%">
                <MasterTableView AutoGenerateColumns="False" DataKeyNames="ID" ClientDataKeyNames="ID"
                    Width="100%">

                    <PagerStyle Mode="NextPrevAndNumeric"></PagerStyle>
                    <Columns>
                        <telerik:GridBoundColumn DataField="UserName" UniqueName="UserName" SortExpression="UserName">
                        </telerik:GridBoundColumn>
                        <telerik:GridBoundColumn DataField="Email" UniqueName="Email" SortExpression="Email">
                        </telerik:GridBoundColumn>
                        <telerik:GridBoundColumn DataField="FullName" UniqueName="FullName" SortExpression="FullName">
                        </telerik:GridBoundColumn>
                        <telerik:GridBoundColumn UniqueName="CompanyName" SortExpression="CompanyName" DataField="CompanyName">
                        </telerik:GridBoundColumn>
                        <telerik:GridTemplateColumn UniqueName="LastLoginDate" SortExpression="LastLoginDate" DataField="LastLoginDate">
                            <ItemTemplate>
                                <asp:Label ID="LastLoginDateLabel" Text='<%# (DateTime) Eval("LastLoginDate") == DateTime.MinValue ? String.Empty : Eval("LastLoginDate") %>'
                                    runat="server" />
                            </ItemTemplate>
                        </telerik:GridTemplateColumn>
                        <telerik:GridBoundColumn DataField="Group" UniqueName="Group" SortExpression="Group">
                        </telerik:GridBoundColumn>
                        <telerik:GridBoundColumn DataField="Role" UniqueName="Role" SortExpression="Role">
                        </telerik:GridBoundColumn>
                        <telerik:GridCheckBoxColumn DataField="AuditUser" UniqueName="AuditUser" SortExpression="AuditUser" />
                        <telerik:GridDateTimeColumn DataField="DateCreated" UniqueName="DateCreated" SortExpression="DateCreated">
                        </telerik:GridDateTimeColumn>
                        <telerik:GridTemplateColumn DataField="IsActive" UniqueName="IsActive" SortExpression="IsActive" GroupByExpression="IsActive GROUP BY IsActive"
                            HeaderStyle-Width="95">
                            <ItemStyle VerticalAlign="Middle" HorizontalAlign="Center" />
                            <FilterTemplate>
                                <telerik:RadComboBox ID="RadComboBox1" runat="server" HighlightTemplatedItems="true"
                                    OnClientSelectedIndexChanged="SelectedIndexChanged" Width="80" AutoPostBack="false"
                                    AllowCustomText="true" MarkFirstMatch="true" SelectedValue='<%#Container.OwnerTableView.GetColumn("IsActive").CurrentFilterValue%>'>
                                    <Items>
                                        <telerik:RadComboBoxItem Selected="true" Text="All" Value="" Font-Names="segoe ui,arial,sans-serif"
                                            Font-Size="8" />
                                        <telerik:RadComboBoxItem Text="Inactive" Value="False" Font-Names="segoe ui,arial,sans-serif"
                                            Font-Size="8" ImageUrl="Images/Icons/UserUnActive.png" />
                                        <telerik:RadComboBoxItem Text="Active" Value="True" Font-Names="segoe ui,arial,sans-serif"
                                            Font-Size="8" ImageUrl="Images/Icons/UserActive.png" />
                                    </Items>
                                </telerik:RadComboBox>
                                <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">

                                    <script type="text/javascript">
                                        function SelectedIndexChanged(sender, args) {
                                            var tableView = $find("<%# ((GridItem)Container).OwnerTableView.ClientID %>");
                                            tableView.filter("IsActive", args.get_item().get_value(), "EqualTo");
                                        }
                                    </script>

                                </telerik:RadScriptBlock>
                            </FilterTemplate>
                            <ItemTemplate>
                                <asp:LinkButton ID="lbActivate" runat="server" CommandName="Activation" OnClientClick='<%#this.getUserActivateMessage(bool.Parse(DataBinder.Eval(Container.DataItem, "IsActive").ToString()),DataBinder.Eval(Container.DataItem, CxUsersScreenDataHelper.UsersTableSchema.UserNameColumn).ToString())%>'>
                                <img alt="active" title="<%#this.getUserActiveImageTooltip(bool.Parse(DataBinder.Eval(Container.DataItem, "IsActive").ToString()))%>" src="<%#this.getUserActiveImageUrl(bool.Parse(DataBinder.Eval(Container.DataItem, "IsActive").ToString()))%>" />
                                </asp:LinkButton>
                                &nbsp;
                                &nbsp;
                                <asp:LinkButton ID="lbResetPassword" OnClientClick='<%#string.Format("CallOpenChangePassword(\"{0}\", \"{1}\"); return false;", Eval("ID"), Eval("UserName"))%>' runat="server">
                                    <img alt="reset password" id="imgResetPassword" runat="server" src="Images/Icons/resetpassword.png" height="16" />
                                </asp:LinkButton>
                            </ItemTemplate>
                        </telerik:GridTemplateColumn>
                        <telerik:GridTemplateColumn UniqueName="Action" HeaderStyle-Width="30" AllowFiltering="false" Groupable="false">
                            <FilterTemplate>
                            </FilterTemplate>
                            <ItemStyle VerticalAlign="Middle" HorizontalAlign="Center" />
                            <ItemTemplate>
                                <asp:LinkButton ID="lbDelete" runat="server" CommandName="Delete">
                                    <img alt="delete" id="imgDelete" runat="server" src="Images/Icons/delete.png" />
                                </asp:LinkButton>
                            </ItemTemplate>
                        </telerik:GridTemplateColumn>
                    </Columns>
                    <SortExpressions>
                        <telerik:GridSortExpression FieldName="IsActive" SortOrder="Descending"></telerik:GridSortExpression>
                    </SortExpressions>
                </MasterTableView>
                <ClientSettings ReorderColumnsOnClient="True" AllowDragToGroup="True" AllowColumnsReorder="True"
                    AllowGroupExpandCollapse="true" EnablePostBackOnRowClick="false">
                    <Resizing AllowRowResize="false" AllowColumnResize="True" EnableRealTimeResize="True"
                        ResizeGridOnColumnResize="False"></Resizing>
                    <Selecting AllowRowSelect="true" />
                    <ClientEvents OnRowSelected="RowSelected"></ClientEvents>
                    <ClientEvents OnMasterTableViewCreated="MTVCreated" />                    
                    <ClientEvents OnCommand="GridCommand" />
                </ClientSettings>
                <PagerStyle AlwaysVisible="True" Mode="Slider" />
                <GroupingSettings ShowUnGroupButton="true" />
                <ExportSettings Pdf-PaperSize="A4" Pdf-PageTitle="Users" FileName="Users" Pdf-PageHeight="210mm"
                    Pdf-PageWidth="297mm">
                </ExportSettings>
            </CX:CxGrid>
            <br />
            <asp:Panel ID="pnlWrapper" runat="server">
                <div style="display: none">
                    <asp:Button ID="btnUserDetail" runat="server" OnClick="btnUserDetail_Click" UseSubmitBehavior="false" />
                    <asp:HiddenField ID="hdnSelUserID" runat="server" />
                </div>
                <asp:Panel ID="pnlDetails" runat="server" Visible="false">
                    <telerik:RadTabStrip ID="UserTabStrip" ValidationGroup="_edit" runat="server" MultiPageID="mpUserData"
                        SelectedIndex="0" Skin="Silk">
                        <Tabs>
                            <telerik:RadTab Text="User Details" PageViewID="pvUserDet">
                            </telerik:RadTab>
                            <telerik:RadTab Text="Security" PageViewID="pvSecurity">
                            </telerik:RadTab>
                        </Tabs>
                    </telerik:RadTabStrip>
                    <telerik:RadMultiPage ID="mpUserData" runat="server" SelectedIndex="0">
                        <telerik:RadPageView ID="pvUserDet" runat="server">
                            <div class="DetailsContentContainer white" style="border-bottom: none;">
                                <div style="padding: 5px 5px 5px 25px">
                                    <table border="0" cellpadding="3" cellspacing="3" style="padding-right: 30px">
                                        <colgroup>
                                            <col width="150" />
                                            <col width="450" />
                                        </colgroup>
                                        <tr>
                                            <td>
                                                <label id="lblFName" for="txtFirstName" runat="server">
                                                </label>
                                            </td>
                                            <td>
                                                <asp:TextBox ID="txtFirstName" runat="server" Width="250" TabIndex="2" MaxLength="50"></asp:TextBox>
                                                <asp:RequiredFieldValidator ValidationGroup="_edit" ID="rqfFName" runat="server"
                                                    ControlToValidate="txtFirstName" ErrorMessage="Required Field"></asp:RequiredFieldValidator>
                                            </td>
                                            <td rowspan="10" style="vertical-align: top">
                                                <table cellpadding="0" cellspacing="0">
                                                    <tr>
                                                        <td style="vertical-align: top; padding-right: 5px;">
                                                            <label id="lbTree" runat="server" enableviewstate="false">
                                                            </label>
                                                            :
                                                        </td>
                                                        <td style="border: 1px solid #c3d9f9; padding: 0px 10px -10px 10px; width: 300px">
                                                            <telerik:RadTreeView runat="server" ID="groupsTree" Style="width: auto; min-width: 300px;"
                                                                Height="330" Skin="Silk" CheckBoxes="true" BorderStyle="None" BorderWidth="2"
                                                                CausesValidation="false" OnClientNodeClicked="treeNodeClicked" TriStateCheckBoxes="false"
                                                                OnClientNodeChecked="nodeCheck" CheckChildNodes="false">
                                                            </telerik:RadTreeView>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td></td>
                                                        <td>
                                                            <asp:CustomValidator ID="cvTeams" runat="server" ClientValidationFunction="CheckTeams"
                                                                OnServerValidate="cvTeams_ServerValidate" ValidationGroup="_edit" ErrorMessage="Select at least one team"></asp:CustomValidator>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <label id="lblLName" for="txtLastName" runat="server" enableviewstate="false">
                                                </label>
                                            </td>
                                            <td>
                                                <asp:TextBox ID="txtLastName" runat="server" Width="250" TabIndex="2" MaxLength="50"></asp:TextBox>
                                                <asp:RequiredFieldValidator ID="rqfLName" ValidationGroup="_edit" runat="server"
                                                    ControlToValidate="txtLastName" ErrorMessage="Required Field"></asp:RequiredFieldValidator>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <label style="width: 100;" id="lblCompany" for="txtCompany" runat="server" enableviewstate="false">
                                                </label>
                                            </td>
                                            <td>
                                                <asp:TextBox ID="txtCompany" ReadOnly="true" runat="server" Width="250" TabIndex="2"></asp:TextBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <label id="lblJob" for="txtJobTitle" runat="server" enableviewstate="false">
                                                </label>
                                            </td>
                                            <td>
                                                <asp:TextBox ID="txtJobTitle" runat="server" Width="250" TabIndex="2" MaxLength="50"></asp:TextBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <label id="lblEmail" for="txtEmail" runat="server" enableviewstate="false">
                                                </label>
                                            </td>
                                            <td>
                                                <asp:TextBox ID="txtEmail" runat="server" Width="250" TabIndex="2" MaxLength="120"></asp:TextBox>
                                                <asp:HiddenField ID="hdnEmail" runat="server" />
                                                <asp:RequiredFieldValidator ID="rqfEmail" runat="server" Display="Dynamic" ControlToValidate="txtEmail"
                                                    ValidationGroup="_edit" ErrorMessage="Required Field"></asp:RequiredFieldValidator>
                                                <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail"
                                                    ValidationGroup="_edit" ErrorMessage="Enter valid email" Display="Dynamic"></asp:RegularExpressionValidator>
                                                <asp:CustomValidator ID="cvEmail" runat="server" ControlToValidate="txtEmail" ClientValidationFunction="isValidEmail"
                                                    ValidationGroup="_edit" ErrorMessage="EMAIL_ALREADY_EXIST"></asp:CustomValidator>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <label id="lblPhone" for="txtPhone" runat="server" enableviewstate="false">
                                                </label>
                                            </td>
                                            <td>
                                                <asp:TextBox ID="txtPhone" runat="server" Width="250" TabIndex="2" MaxLength="50" OnTextChanged="txtPhone_TextChanged"></asp:TextBox>
                                                <asp:RegularExpressionValidator ValidationGroup="_edit" ID="revPhone" runat="server"
                                                    ErrorMessage="Phone number is not valid" Display="Dynamic" ValidationExpression="[\d|\-|\s|\.|\+|\(|\)]+"
                                                    ControlToValidate="txtPhone"></asp:RegularExpressionValidator>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <label id="lblCell" for="txtCell" runat="server" enableviewstate="false">
                                                </label>
                                            </td>
                                            <td>
                                                <asp:TextBox ID="txtCell" runat="server" Width="250" TabIndex="2" MaxLength="50"></asp:TextBox>
                                                <asp:RegularExpressionValidator ValidationGroup="_edit" ID="revCellPhone" runat="server"
                                                    Display="Dynamic" ValidationExpression="[\d|\-|\s|\.|\+|\(|\)]+" ControlToValidate="txtCell"></asp:RegularExpressionValidator>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <label id="lblRole" for="ddlRole" runat="server" enableviewstate="false">
                                                </label>
                                            </td>
                                            <td>
                                                <table cellpadding="0" cellspacing="0">
                                                    <tr>
                                                        <td>
                                                            <telerik:RadComboBox ID="ddlRole" runat="server" Width="253" Skin="Silk" OnClientSelectedIndexChanged="roleChanged">
                                                            </telerik:RadComboBox>
                                                            <div class="scanner chk" id="scannerNotExploitable" runat="server" style="display: none">
                                                                <asp:CheckBox ID="chkChangeNotExploitable" Style="vertical-align: middle" runat="server" />
                                                            </div>
                                                            <div class="scanner chk" id="scannerDelete" runat="server" style="display: none">
                                                                <asp:CheckBox ID="chkScannerDelete" Style="vertical-align: middle" runat="server" />
                                                            </div>
                                                            <div id="reviewer" style="display: none" runat="server" class="chk">
                                                                <asp:CheckBox ID="chkModifyResults" Style="vertical-align: middle" runat="server" Text="ALLOW_SEVERITY_STATUS_CHANGES" />
                                                            </div>
                                                        </td>
                                                        <td>
                                                            <asp:RequiredFieldValidator ID="rqfRole" ValidationGroup="_edit" ControlToValidate="ddlRole"
                                                                runat="server"></asp:RequiredFieldValidator>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <label id="lblAudit" for="txtCell" runat="server" enableviewstate="false">
                                                </label>
                                            </td>
                                            <td>
                                                <asp:CheckBox ID="txtAudit" runat="server" Width="250" TabIndex="2" MaxLength="50"></asp:CheckBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <label id="lblSkype" for="txtSkype" runat="server">
                                                </label>
                                            </td>
                                            <td>
                                                <asp:TextBox ID="txtSkype" runat="server" Width="250" TabIndex="3" MaxLength="120"></asp:TextBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <label id="lblLanguage" runat="server">
                                                </label>
                                            </td>
                                            <td>
                                                <telerik:RadComboBox ID="ddlLanguage" runat="server" Display="Dynamic" Width="253"
                                                    DataTextField="GroupName" Skin="Silk" DataValueField="ID" AutoCompleteSeparator=";"
                                                    MarkFirstMatch="True" AutoPostBack="false" CausesValidation="false">
                                                </telerik:RadComboBox>
                                            </td>
                                            <td></td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <label id="lblExpired" for="radExpDate" enableviewstate="false" runat="server">
                                                </label>
                                            </td>
                                            <td>
                                                <div id="expirationDateDivLabel" runat="server">
                                                    <label id="noExpirationDateLabel" runat="server"><%=this.GetTermFromResource("NO_EXPIRATION_DATE")%></label>
                                                    <asp:Image ID="noExpirationDateImage" Style="margin-left: 4px; margin-bottom: -5px;" ImageUrl="~/Images/Icons/help16.png" CssClass="HelpIcon" runat="server" />
                                                </div>
                                                <div id="expirationDateDivDatePicker">
                                                    <telerik:RadDatePicker ID="radExpDate" runat="server" DateInput-DateFormat="d" Width="152" DateInput-ClientEvents-OnDisable="fixDisableDisappear"
                                                        EnableTyping="False">
                                                        <Calendar ID="Calendar1" runat="server" FastNavigationStep="12">
                                                        </Calendar>
                                                    </telerik:RadDatePicker>
                                                </div>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                        </telerik:RadPageView>
                        <telerik:RadPageView ID="pbSecurity" runat="server">
                            <div class="SecurityContainer DetailsContentContainer white">
                                <div class="SecurityContainerContent">
                                    <input type="hidden" id="hdnClientIP" value="<%= this.m_UtilityMethods.GetIPAddress() %>" />
                                    <div class="IPLimitContainer">
                                        <input type="checkbox" id="ipLimitEnable" runat="server" onchange="toggleEnableIPLimiters(true)" />
                                        <label class="label" runat="server" id="lblLimitAccessByIP"></label>
                                    </div>
                                    <div>
                                        <div class="IPAddressContainer">
                                            <label class="IPlabel" id="lblIPAddress1" runat="server"></label>
                                            <input type="text" id="txtIPAddress1" runat="server" class="txtIPAddress"/>
                                            <asp:RegularExpressionValidator runat="server" ValidationGroup="_edit" Display="Dynamic" ValidationExpression="<%# UserManagement.IP_ADDRESS_REGEX %>" ID="ipAddress1Validator" ErrorMessage="EnterValidIP" ControlToValidate="txtIPAddress1"></asp:RegularExpressionValidator>
                                        </div>
                                        <div class="IPAddressContainer">
                                            <label class="IPlabel" id="lblIPAddress2" runat="server"></label>
                                            <input type="text" id="txtIPAddress2" runat="server" class="txtIPAddress"/>
                                            <asp:RegularExpressionValidator runat="server" ValidationGroup="_edit" Display="Dynamic" ValidationExpression="<%# UserManagement.IP_ADDRESS_REGEX %>" ID="ipAddress2Validator" ErrorMessage="EnterValidIP" ControlToValidate="txtIPAddress2"></asp:RegularExpressionValidator>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </telerik:RadPageView>
                    </telerik:RadMultiPage>
                    <div class="DetailsContentContainer" style="min-height: 33px; padding-left: 25px;" class="bottomTabColor">
                        <table cellpadding="2" cellspacing="2" border="0">
                            <tr>
                                <td>
                                    <telerik:RadButton ID="btnUpdate" runat="server" ValidationGroup="_edit" CausesValidation="true"
                                        OnClick="btnUpdate_Click" EnableViewState="false" UseSubmitBehavior="true" OnClientClicked="updateClick">
                                        <Icon SecondaryIconCssClass="rbOk" SecondaryIconRight="4" SecondaryIconTop="4" />
                                    </telerik:RadButton>
                                </td>
                                <td>
                                    <telerik:RadButton ID="btnCancel" runat="server" Style="display: none" CausesValidation="false"
                                        EnableViewState="false" UseSubmitBehavior="false" AutoPostBack="false" OnClientClicked="updateClick">
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
    <script src="TableSort.js" type='text/javascript' language='javascript'></script>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="script" runat="Server">
</asp:Content>
