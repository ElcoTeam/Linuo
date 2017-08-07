<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RoleDetailInfo.aspx.cs" Inherits="LiNuoMes.UserManage.RoleDetailInfo" %>

<!DOCTYPE html>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title></title>
       <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="renderer" content="webkit">
    
    <script src="../Content/scripts/jquery-1.11.1.min.js"></script>
    <script src="../Content/scripts/bootstrap/bootstrap.min.js"></script>
    <script type="text/javascript" src="../js/m.js" charset="gbk"></script>
    <script src="../js/pdfobject.js" type="text/javascript"></script>
    <link href="../Content/scripts/plugins/jquery-ui/jquery-ui.min.css" rel="stylesheet" />
    <script src="../Content/scripts/plugins/jquery-ui/jquery-ui.min.js"></script>
    <!-- Bootstrap -->
    <link rel="stylesheet" type="text/css" href="../css/bootstrap.min.css" />
    <link href="../Content/styles/font-awesome.min.css" rel="stylesheet" />
    <%--<link href="../css/learun-ui.css" rel="stylesheet" />--%>
    <link href="../Content/adminLTE/css/index.css" rel="stylesheet" />
    <link href="../Content/scripts/plugins/jqgrid/jqgrid.css" rel="stylesheet" />
    <link rel="Shortcut icon" href="http://www.jq22.com/favicon.ico" />
    <link href="../Content/styles/learun-ui.css?v=xGgPBYcCVZtMx26lXm_bETZOl5nvwnNwIiq-fpPtywo1" rel="stylesheet" />
    <link href="../css/my.css" rel="stylesheet" media="screen">
    <script src="../Content/scripts/plugins/layout/jquery.layout.js"></script>
    <script src="../Content/scripts/plugins/dialog/dialog.js"></script>
    
    <script src="../Content/scripts/plugins/jqgrid/grid.locale-cn.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/jqgrid.min.js"></script>
    <script src="../Content/scripts/utils/learun-ui.js"></script>
    <script src="../Content/scripts/utils/learun-form.js"></script>
    <link href="../css/zTreeStyle/metro.css" rel="stylesheet" />
    <script src="../js/jquery.ztree.all-3.5.min.js"></script>
    <script src="../Content/scripts/plugins/validator/validator.js"></script>
    <style>
        html, body {
            height: 100%;
            width: 100%;
        }
    </style>
</head>
<body>
     <script>         $(function () {
             InitialPage();
             //getSession();
         });         //初始化页面         function InitialPage() {
             //layout布局
             $('#layout').layout({
                 applyDemoStyles: true,
                 west: {
                     size: $(window).width() * 0.5
                 },
                 spacing_open: 0,
                 onresize: function () {
                     $(window).resize()
                 }
             });
             //$(".center-Panel").height($(window).height())
             $(".west-Panel").height($(window).height());
         }         //保存表单
         function AcceptClick(grid) {
             if (!$('#ruleinfo').Validform()) {
                 return false;
             }
             var RoleID="";
             var rolename = $('#RoleName').val();
             var description = $('#Description').val();
             var treeObj = $.fn.zTree.getZTreeObj("tree");
             var checkedNodes = treeObj.getCheckedNodes();
             var selectid = [];
             if(checkedNodes.length<=0){
                 dialogMsg("请至少选择一种权限", 0);
                 return false;
             }
             for (var i = 0; i < checkedNodes.length; i++) {
                 selectid.push(checkedNodes[i].id);
             }
             $.ajax({
                 url: "RoleDetailInfo.aspx/SaveRoleInfo",
                 data: JSON.stringify({RoleID: RoleID, RoleName: rolename, Description: description, arr: selectid }),
                 type: "post",
                 async: true,
                 dataType: "json",
                 contentType: "application/json;charset=utf-8",
                 success: function (data) {
                     if (data.d == "success") {
                         Loading(false);
                         dialogMsg("保存成功", 1);
                         dialogClose();
                         grid.trigger("reloadGrid");
                     }
                     else if (data.d == "falut") {
                         dialogMsg("保存失败", -1);
                     }
                     else if (data.d == "hasexit") {
                         dialogMsg("已存在此角色", 0);
                     }
                     
                 },
                 error: function (XMLHttpRequest, textStatus, errorThrown) {
                     Loading(false);
                     dialogMsg(errorThrown, -1);
                 },
                 beforeSend: function () {
                     Loading(true, "正在保存数据");
                 },
                 complete: function () {
                     Loading(false);
                 }
             });
             
         }         function request(name) {
             var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
             var r = window.location.search.substr(1).match(reg);
             if (r != null) return unescape(r[2]); return null;
         }         var zTree;
         var demoIframe;

         var setting = {
             check: {
                 enable: true
             },
             view: {
                 //addHoverDom: addHoverDom,
                 //removeHoverDom: removeHoverDom,
                 dblClickExpand: false,
                 showLine: true,
                 selectedMulti: false
             },
             data: {
                 simpleData: {
                     enable: true,
                     idKey: "id",
                     pIdKey: "pId",
                     rootPId: ""
                 }
             },
             callback: {
                 beforeClick: function (treeId, treeNode) {
                     var zTree = $.fn.zTree.getZTreeObj("tree");
                     if (treeNode.isParent) {
                         zTree.expandNode(treeNode);
                         return false;
                     } else {
                         demoIframe.attr("src", treeNode.file + ".html");
                         return true;
                     }
                 }
                 
             }
         };

         var zNodes = [];//所有节点

         $(document).ready(function () {
             $.ajax({    
                 url: '../Login/fMenu.aspx/GetRoleTree',
                 type: "post",
                 contentType: "application/json; charset=utf-8",
                 dataType: "json",
                 async: false,                      
                 success: function (data) {
                     zNodes = eval(data.d);
                 },    
                 error: function () {   
                       alert("Ajax请求数据失败!");
                 }
             });

             var t = $("#tree");
             t = $.fn.zTree.init(t, setting, zNodes);
             demoIframe = $("#testIframe");
             demoIframe.bind("load", loadReady);
             
         });

         function loadReady() {
             var bodyH = demoIframe.contents().find("body").get(0).scrollHeight,
                     htmlH = demoIframe.contents().find("html").get(0).scrollHeight,
                     maxH = Math.max(bodyH, htmlH), minH = Math.min(bodyH, htmlH),
                     h = demoIframe.height() >= maxH ? minH : maxH;
             if (h < 530) h = 530;
             demoIframe.height(h);
         }    </script>
    <div class="ui-layout" id="layout" style="height: 100%; width: 100%;">
      <div class="ui-layout-west">
        <div class="west-Panel" style="margin: 0px; border-top: none; border-left: none; border-bottom: none;">
            <div style="color:#9f9f9f;padding-top:5px; padding-bottom:5px;padding-left:8px;"><i style="padding-right:5px;" class="fa fa-info-circle"></i><span>填写角色基本信息</span></div>
            <table class="form" id="ruleinfo" style="margin-top:10px;">
                <tr>
                    <th class="formTitle">角色名称<font face="宋体">*</font></th>
                    <td class="formValue">
                         <input type="text" class="form-control" id="RoleName" placeholder="请输入角色名称" isvalid="yes" checkexpession="NotNull">
                    </td>
                </tr>
               <tr>
                    <th class="formTitle" valign="top" style="padding-top: 4px;">
                        角色说明
                    </th>
                </tr>
                <tr>
                    <td class="formValue" colspan="2">
                        <textarea id="Description"  class="form-control" style="height: 210px; margin-left:5px;"  placeholder="请输入角色说明"></textarea>
                    </td>
                </tr>
               
            </table>
        </div>
    </div>
    <div class="ui-layout-center">
            
           <div class="center-Panel" style="margin: 0px; border-right: none; border-left: none; border-bottom: none; background-color: #fff; overflow: auto; padding-bottom: 10px;">
               <div style="color:#9f9f9f;padding-top:5px; padding-bottom:5px;padding-left:8px;"><i style="padding-right:5px;" class="fa fa-info-circle"></i><span>选择角色权限</span></div>
            
                <ul id="tree" class="ztree" style="overflow:auto;"></ul>
        </div>
    </div>
   </div>
    <style>
    .form .formTitle {
        width:65px;
        font-size:9pt;
    }
  
    </style>

</body>
</html>
