<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EquSecondLevelMaintence.aspx.cs" Inherits="LiNuoMes.Equipment.EquSecondLevelMaintence" %>

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
   <%-- <link href="../Content/scripts/bootstrap/bootstrap.css" rel="stylesheet" />--%>
    <link href="../Content/bootstrap.min.css" rel="stylesheet" />
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
    <link href="../Content/styles/learun-ui.css" rel="stylesheet" />
    <link rel="stylesheet" type="text/css" href="../css/iziModal.css">
    <link href="../Content/scripts/plugins/wizard/wizard.css" rel="stylesheet" />
    <script src="../Content/scripts/plugins/layout/jquery.layout.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/grid.locale-cn.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/jqgrid.min.js"></script>
    <script src="../Content/scripts/plugins/tree/tree.js"></script>
    <script src="../Content/scripts/plugins/validator/validator.js"></script>
    <script src="../Content/scripts/plugins/wizard/wizard.js"></script>
    <script src="../Content/scripts/utils/learun-ui.js"></script>
    <script src="../Content/scripts/utils/learun-form.js"></script>
    <script src="../js/iziModal.min.js" type="text/javascript"></script>
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

         var actionname = request('actionname');
         
         $(function () {
             var id = '<%=Session["UserName"] %>';
             $("#PmOper").val(id);
             InitialPage();
             GetGrid();
             buttonOperation();
         });
         //初始化页面
         function InitialPage() {
            
             //加载导向
             $('#wizard').wizard().on('change', function (e, data) {
                 var $finish = $("#btn_finish");
                 var $next = $("#btn_next");
                
             });
             
             //resize重设(表格、树形)宽高
             $(window).resize(function (e) {
                 window.setTimeout(function () {
                     $("#gridTable").setGridHeight($(window).height());
                 }, 200);
                 e.stopPropagation();
             });

             $.ajax({
                // url: "EquSecondLevelMaintence.aspx/GetSecondLevelList",
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
                         _html += '        <img src="/Equipment/images/' + imgName + '" />';
                         _html += '    </div>';
                         _html += '    <div id="' + row.PmPlanCode + '" class="card-box-content">';
                         _html += '        <p>工序名称：' + row.ProcessName + '</p>';
                         _html += '        <p>设备名称：' + row.DeviceName + '</p>';
                         _html += '        <p>保养计划：<a id="btn_Search1" class="btn-link" onclick=\"btn_look(\'' + row.PmSpecCode + '\')\" >' + row.PmPlanName + '</a></p>';
                         _html += '    </div><i></i>';
                         _html += '</div>';
                     });
                     $(".gridPanel1").html(_html);
                     $(".card-box").click(function () {
                         if (!$(this).hasClass("active")) {
                             $(this).addClass("active")
                             $("#btn_next").removeAttr('disabled');
                             
                         } else {
                             $(this).removeClass("active")
                             $("#btn_next").attr('disabled', 'disabled');
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

         }


         //加载表格
         function GetGrid() {
             var userIds = [];
             $('.gridPanel1 .active .card-box-content').each(function () {
                 userIds.push($(this).attr('id'));
             });
             var selectedRowIndex = 0;
             var $gridTable = $('#gridTable');
             $gridTable.jqGrid({
                 url: "hs/GetMaintenceList.ashx",
                 datatype: "json",
                 postData: { DeviceCode: userIds },
                 height: $(window).height() * 0.7,
                 width: $('#wizard').width(),
                 colModel: [
                    
                     {
                         label: '点检日期', name: 'PmDate', index: 'PmDate', width: 80, align: 'left', sortable: false
                     },
                     { label: '设备编号', name: 'DeviceCode', index: 'DeviceCode', width: 80, align: 'left', sortable: false },
                     {
                         label: '设备名称', name: 'DeviceName', index: 'DeviceName', width: 200, align: 'left', sortable: false
                     },
                     {
                         label: '保养工时', name: 'MaintenceTime', index: 'MaintenceTime', width: 80, align: 'left', sortable: false
                     },
                     {
                         label: '保养前存在问题', name: 'InspectionProblem', index: 'InspectionProblem', width: 200, align: 'left', sortable: false
                     },
                     {
                         label: '电源线绝缘', name: 'PowerLine', index: 'PowerLine', width: 80, align: 'left', sortable: false
                     },
                     {
                         label: '接地线', name: 'GroundLead', index: 'GroundLead', width: 80, align: 'left', sortable: false
                     },
                     {
                         label: '更换配件部位', name: 'ReplacePart', index: 'ReplacePart', width: 100, align: 'left', sortable: false
                     },
                     {
                         label: '更换配件名称', name: 'ReplaceName', index: 'ReplaceName', width: 100, align: 'left', sortable: false
                     },
                     {
                         label: '更换配件件数', name: 'ReplaceCount', index: 'ReplaceCount', width: 100, align: 'left', sortable: false
                     },
                 ],
                 shrinkToFit: false,
                 autowidth: false,
                 scroll:true,
                 gridview: true,
                 onSelectRow: function () {
                     selectedRowIndex = $("#" + this.id).getGridParam('selrow');
                 },
                 gridComplete: function () {
                     $("#" + this.id).setSelection(selectedRowIndex, false);

                 }
             });

         }

         //新建
         function btn_add(event) {
             var userIds = [];
             //var productcatagory = [];
             $('.gridPanel1 .active .card-box-content').each(function () {
                 userIds.push($(this).attr('id'));
                 //productcatagory.push($(this).find('p:eq(1)').html());
             });
             dialogOpen({
                 id: "Form1",
                 title: '二级保养点检信息记录',
                 url: '../Equipment/EquSecondLevelAdd.aspx?equid=' + userIds + '',
                 width: "750px",
                 height: "500px",
                 async: false,
                 callBack: function (iframeId) {
                     console.log(top.frames[iframeId]);
                     top.frames[iframeId].AcceptClick($("#gridTable"));
                 }
             });
         }

         //按钮操作（上一步、下一步、完成、关闭）
         function buttonOperation() {
             var $finish = $("#btn_finish");
             //完成提交保存
             $finish.click(function () {
                 //AcceptClick1(actionname);
                 SaveDialog();
             })
         }

         function SaveDialog()
         {
             //top.frames["Form"].reload();
             AcceptClick();
         }

         //保存表单
         function AcceptClick() {
             
             var userIds = [];
             //var productcatagory = [];
             $('.gridPanel1 .active .card-box-content').each(function () {
                 userIds.push($(this).attr('id'));
                 //productcatagory.push($(this).find('p:eq(1)').html());
             });

             //var PmStartDate = $("#PmStartDate").val().trim();
             //var PmFinishDate = $("#PmFinishDate").val();
             var PmOper = $("#PmOper").val();
             var PmComment = $("#PmComment").val();

             //if (userIds.length==0)
             //{
             //    dialogMsg('当日无需要维护的二级保养计划', 0);
             //    return false;
             //}

             if (!$('#ruleinfo').Validform()) {
                 return false;
             }
             $.ajax({
                 url: "../Equipment/hs/GetEquMaintenceManCRUD.ashx",
                 traditional: true,
                 data:{
                     Action: "ExcuteSecondLevelEquMaintenceMan",
                     PmOper: PmOper,
                     PmComment: PmComment,
                     PmList: userIds
                 },
                 async: true,
                 type: "post",
                 datatype: "json",
                 success: function (data) {
                     Loading(false);
                     data = JSON.parse(data);
                     if (data.result == "success") {
                         //window.parent.location.reload();
                         window.parent.$('#gridTable').trigger("reloadGrid");
                         dialogMsg("保存成功", 1);
                         dialogClose();
                         //grid.trigger("reloadGrid");
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
                 //contentType: "application/x-www-form-urlencoded; charset=UTF-8",
                 url: './FileSearchInfo.aspx?folderId=' + objID,
                 width: "1000px",
                 height: "800px",
                 btn: null
             });

         }

       
    </script>
<body>
    <div class="widget-body">
         <div id="wizard" class="wizard" data-target="#wizard-steps" style="border-left: none; border-top: none; border-right: none;">
                <ul class="steps">
                     <li data-target="#step-1" class="active"><span class="step">1</span>基本信息<span class="chevron"></span></li>
                     <li data-target="#step-2"><span class="step">2</span>保养内容<span class="chevron"></span></li>
                </ul>
          </div>
          <div class="step-content" id="wizard-steps" style="border-left: none; border-bottom: none; border-right: none;">
          <div class="step-pane active" id="step-1" style="margin-left: 0px; margin-top: 15px; margin-right: 30px;">
              
               <div class="treesearch">
                  <input id="txt_TreeKeyword" type="text" class="form-control" style="border-top: none;" placeholder="请输入要查询关键字" />
                  <span id="btn_TreeSearch" class="input-query" title="Search"><i class="fa fa-search"></i></span>
               </div>
               <div class="center-Panel" style="margin: 0px; border-right: none; border-left: none; border-bottom: none; background-color: #fff; overflow: auto; padding-bottom: 10px;">
               <div class="gridPanel1">
               </div>
               </div>
          </div>
         <div class="step-pane" id="step-2" style="margin: 5px;">
             
            <div class="titlePanel">
            <div class="toolbar">
                <div class="btn-group">
                    <a id="lr-add" class="btn btn-default" onclick="btn_add(event)"><i class="fa fa-plus"></i>&nbsp;新增</a>
                    <a id="lr-delete" class="btn btn-default" onclick="btn_delete(event)"><i class="fa fa-trash-o"></i>&nbsp;删除</a>
                </div>
            </div>
            </div>
            <div class="rows" style="margin-top:0.5%; overflow: hidden; ">
             
              <div class="gridPanel">
                   <table id="gridTable"></table>
              </div>
             </div>
           
         </div>
         
         </div>
   
    </div>

    <div class="form-button" id="wizard-actions">
            <a id="btn_last" disabled class="btn btn-default btn-prev">上一步</a>
            <a id="btn_next" disabled  class="btn btn-default btn-next">下一步</a>
            <a id="btn_finish"  class="btn btn-success" style="width:60px;">完成</a>
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
    </style>
</body>
</html>
