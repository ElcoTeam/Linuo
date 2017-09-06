<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EquFirstLevelMaintence.aspx.cs" Inherits="LiNuoMes.Equipment.EquFirstLevelMaintence" %>

<!DOCTYPE html>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
       <meta charset="UTF-8" name="viewport" content="width=device-width" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>用户管理</title>
    <%--<link rel="stylesheet" type="text/css" href="../css/bootstrap.min.css" />--%>
    <%-- <link rel="stylesheet" type="text/css" href="../bootstrap-3.3.6/css/bootstrap.min.css" />--%>
    <!--框架必需start-->
    <script src="../Content/scripts/jquery-1.11.1.min.js"></script>
    <link href="../Content/styles/font-awesome.min.css" rel="stylesheet" />
    <link href="../Content/scripts/plugins/jquery-ui/jquery-ui.min.css" rel="stylesheet" />
    <script src="../Content/scripts/plugins/jquery-ui/jquery-ui.min.js"></script>
    <!--框架必需end-->
    <!--bootstrap组件start-->
    <link href="../Content/scripts/bootstrap/bootstrap.css" rel="stylesheet" />
    <%--<link rel="stylesheet" type="text/css" href="../css/bootstrap.min.css" />--%>
    <script src="../Content/scripts/bootstrap/bootstrap.min.js"></script>
    <!--bootstrap组件end-->
    <!--jqgrid表格组件start-->

    <!--表格组件end-->
    <!--树形组件start-->

    <!--树形组件end-->
    <!--表单验证组件start-->

    <!--表单验证组件end-->
    <!--日期组件start-->

    <!--日期组件start-->

    <script src="../My97DatePicker/WdatePicker.js"></script>
    <link href="../Content/scripts/plugins/jqgrid/jqgrid.css" rel="stylesheet" />
    <%--<link href="../Content/scripts/plugins/tree/tree.css" rel="stylesheet" />--%>
    <%--<link href="/Content/scripts/plugins/datetime/pikaday.css" rel="stylesheet"/>--%>
    <link href="../Content/styles/learun-ui.css" rel="stylesheet" />
    <link rel="stylesheet" type="text/css" href="../css/iziModal.css">
    <script src="../Content/scripts/plugins/layout/jquery.layout.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/grid.locale-cn.js"></script>

    <script src="../Content/scripts/plugins/jqgrid/jqgrid.min.js"></script>
    <script src="../Content/scripts/plugins/tree/tree.js"></script>
    <script src="../Content/scripts/plugins/validator/validator.js"></script>
    <%--    <script src="/Content/scripts/plugins/datetime/pikaday.js"></script>--%>
    <script src="../Content/scripts/utils/learun-ui.js"></script>
    <script src="../Content/scripts/utils/learun-form.js"></script>
    <link href="../css/void_autocomplete.css" rel="stylesheet" />
    <script src="../js/void_autocomplete.js"></script>

    <style>
        html, body {
            height: 100%;
            width: 100%;
        }
    </style>

</head>

     <script>

         var manuId = request('manuId');
         var actionname = request('actionname');
         var wicode = request('wicode');

         $(function () {
             var id = '<%=Session["UserName"] %>';
             $("#PmOper").val(id);
             InitialPage();
            
         });
         //初始化页面
         function InitialPage() {
             //layout布局
             $('#layout').layout({
                 applyDemoStyles: true,
                 west: {
                     size: $(window).width() * 0.35
                 },
                 spacing_open: 0,
                 onresize: function () {
                     $(window).resize()
                 }
             });

             $(".center-Panel").height($(window).height() - 40)
             $(".west-Panel").height($(window).height());

             $.ajax({
                 url: "EquFirstLevelMaintence.aspx/GetFirstLevelList",
                 data: "{}",
                 type: "post",
                 dataType: "json",
                 contentType: "application/json;charset=utf-8",
                 success: function (data) {
                     if (data == null) return false;
                     
                     var _html = "";
                     $.each(data.d, function (i, row) {
                         var imgName = "Scheme.png";
                         var active = "";
                         if (row.IsActive == 1) {
                             active = "active";
                         }
                         _html += '<div class="card-box shcemeinfocheck ' + active + '">';
                         _html += '    <div class="card-box-img">';
                         _html += '        <img src="/Equipment/images/' + imgName + '"/>';
                         _html += '    </div>';
                         _html += '    <div id="' + row.PmPlanCode + '" class="card-box-content">';
                         _html += '        <p>工序名称：' + row.ProcessName + '</p>';
                         _html += '        <p>设备名称：' + row.DeviceName + '</p>';
                         _html += '        <p>保养计划：<a id="btn_Search1" class=" btn-link" onclick=\"btn_look(\'' + row.PmSpecCode + '\')\" >' + row.PmPlanName + '</a></p>';
                         _html += '    </div><i></i>';
                         _html += '</div>';
                     });
                     $(".gridPanel").html(_html);
                     $(".card-box").click(function () {
                         if (!$(this).hasClass("active")) {
                             $(this).addClass("active")
                            
                         } else {
                             $(this).removeClass("active")
                             
                         }
                     });
                     Loading(false);
                 }, beforeSend: function () {
                     
                     Loading(true);
                 }
             });
             //模糊查询模板（注：这个方法是理由jquery查询）
             $("#txt_TreeKeyword").keyup(function () {
                 var value = $(this).val();
                 if (value != "") {
                     window.setTimeout(function () {
                         $(".shcemeinfocheck")
                          .hide()
                          .filter(":contains('" + (value.toLocaleUpperCase()) + "')")
                          .show();
                     }, 200);
                 } else {
                     $(".shcemeinfocheck").show();
                 }
             }).keyup();

             $.ajax({
                 url: "EquFirstLevelMaintence.aspx/GetFirstLevelTestList",
                 data: "{}",
                 type: "post",
                 dataType: "json",
                 contentType: "application/json;charset=utf-8",
                 success: function (data) {
                     if (data == null) return false;
                     var value = "";
                     $.each(data.d, function (i, row) {
                         value += row.ID + '.' + row.InspectionContent + '\n';
                     });
                     $("#PmComment").val(value);
                     Loading(false);
                 }, beforeSend: function () {
                     Loading(true);
                 }
             });
         }

         //保存表单
         function AcceptClick(grid) {
             var userIds = [];
             //var productcatagory = [];
             $('.gridPanel .active .card-box-content').each(function () {
                 userIds.push($(this).attr('id'));
                 //productcatagory.push($(this).find('p:eq(1)').html());
             });

             var PmOper = $("#PmOper").val();
             var PmComment = $("#PmProblem").val();

             var FindProblem = $("#FindProblem").val();
             var RepairProblem = $("#RepairProblem").val();
             var ReaminProblem = $("#ReaminProblem").val();

             if (userIds.length==0)
             {
                 dialogMsg('请选择保养计划', 0);
                 return false;
             }

             if (!$('#ruleinfo').Validform()) {
                 return false;
             }
             $.ajax({
                 url: "../Equipment/hs/GetEquMaintenceManCRUD.ashx",
                 traditional: true,
                 data:{
                     Action: "ExcuteFirstLevelEquMaintenceMan",
                     PmOper: PmOper,
                     PmComment: PmComment,
                     FindProblem: FindProblem,
                     RepairProblem: RepairProblem,
                     ReaminProblem: ReaminProblem,
                     PmList: userIds
                 },
                 async: true,
                 type: "post",
                 datatype: "json",
                 success: function (data) {
                     Loading(false);
                     data = JSON.parse(data);
                     if (data.result == "success") {
                         dialogMsg("保存成功", 1);
                         dialogClose();
                         grid.trigger("reloadGrid");
                     }
                     else if (data.result == "failed") {
                         dialogMsg(data.msg, -1);
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
         }


         function request(name) {
             var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
             var r = window.location.search.substr(1).match(reg);
             if (r != null) return unescape(r[2]); return null;
         }

         //查看操作规范文档
         function btn_look(objID) {
            
             if (objID == "") {
                 dialogMsg("您还没有上传文档", 0);
                 return false;
             }
             dialogOpen({
                 id: "UploadifyForm",
                 title: '查看文件-' + objID,
                 url: './FileSearchInfo.aspx?folderId=' + objID,
                 width: "1000px",
                 height: "800px",
                 btn: null
             });
             
         }
        
    </script>
<body>
   
    <div class="ui-layout" id="layout" style="height: 100%; width: 100%;">
    <div class="ui-layout-west">
        <div class="west-Panel" style="margin: 0px; border-top: none; border-left: none; border-bottom: none;">
            <div style="color:#9f9f9f;padding-top:5px; padding-bottom:5px;padding-left:8px;"><i style="padding-right:5px;" class="fa fa-info-circle"></i><span style="font-size: 9pt;">填写内容,选择右侧产品型号</span></div>
            <table class="form" id="ruleinfo">
                <tr>
                    <th class="formTitle">保养人<font face="宋体">*</font></th>
                    <td class="formValue">
                        <input id="PmOper" type="text" class="form-control" isvalid="yes" checkexpession="NotNull" readonly/>        
                    </td>
                </tr>

                <tr>
                    <th class="formTitle" valign="top" style="padding-top: 4px;">
                        点检内容
                    </th>
                    <td class="formValue" colspan="3">
                        <textarea id="PmComment"  class="form-control" style="height: 200px;" readonly ></textarea>
                    </td>
                </tr> 

                <tr>
                    <th class="formTitle" valign="top" style="padding-top: 4px;">
                        问题记录
                    </th>
                    <td class="formValue" colspan="3">
                        <textarea id="PmProblem"  class="form-control" style="height: 250px;"  placeholder="请输入问题记录"></textarea>
                    </td>
                </tr> 
                 <tr>
                    <th class="formTitle" valign="top" style="padding-top: 4px;">
                        
                    <td colspan="3" >
                        <ul>
                            <li style="padding-top:10px;">设备进行点检发现问题共<input id="FindProblem" type="text" class="problemcount" isvalid="yes" checkexpession="PositiveNumOrNull" />次</li>
                            <li style="padding-top:10px;">维修解决问题共<input id="RepairProblem"  type="text" class="problemcount" isvalid="yes"/ checkexpession="PositiveNumOrNull" >次</li>
                            <li style="padding-top:10px;">遗留问题存在<input id="ReaminProblem"  type="text" class="problemcount" isvalid="yes" checkexpession="PositiveNumOrNull"/>次</li>
                        </ul>
                    </td>
                </tr>
            </table>
        </div>
    </div>
    <div class="ui-layout-center">
        <div class="treesearch">
            <input id="txt_TreeKeyword" type="text" class="form-control" style="border-top: none;" placeholder="请输入要查询关键字" />
            <span id="btn_TreeSearch" class="input-query" title="Search"><i class="fa fa-search"></i></span>
        </div>
        <div class="center-Panel" style="margin: 0px; border-right: none; border-left: none; border-bottom: none; background-color: #fff; overflow: auto; padding-bottom: 10px;">
            <div class="gridPanel">
            </div>
        </div>
    </div>
   </div>
   <style>
    .form .formValue
    {
        padding-left: 5px;
    }
    /*.form .form-control {
        font-size:9pt;
    }*/
    .form .formTitle { 
        font-size:9pt;
    }
    .card-box-img {
        line-height:initial;
    }
    .card-box-img img {
        width: 58px;
        height: 58px;
        border-radius: 0px;
        margin-left:0px;
    }
    .card-box-content p{
        height: 20px;
    }
     .timeselect{
        width:200px;
        height:30px;
    }
    .problemcount{
        width: 40px; 
        border: none; 
        border-bottom: 1px solid #000;
        text-align: center;
    }
    
    </style>
</body>
</html>
