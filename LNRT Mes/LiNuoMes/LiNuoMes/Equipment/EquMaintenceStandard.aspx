﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EquMaintenceStandard.aspx.cs" Inherits="LiNuoMes.Equipment.EquMaintenceStandard" %>

<!DOCTYPE html>
<html>
<head>
    <title>力诺瑞特平板集热器</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="renderer" content="webkit">
    
    <script src="../Content/scripts/jquery-1.11.1.min.js"></script>
    <script src="../Content/scripts/bootstrap/bootstrap.min.js"></script>
    
    <script src="../js/pdfobject.js" type="text/javascript"></script>
    <link href="../Content/scripts/plugins/jquery-ui/jquery-ui.min.css" rel="stylesheet" />
    <script src="../Content/scripts/plugins/jquery-ui/jquery-ui.min.js"></script>
    <!-- Bootstrap -->
    <link rel="stylesheet" type="text/css" href="../css/bootstrap.min.css" />
    <link href="../Content/styles/font-awesome.min.css" rel="stylesheet" />
    <link href="../css/learun-ui.css" rel="stylesheet" />
    <link href="../Content/adminLTE/css/index.css" rel="stylesheet" />
    <link href="../Content/scripts/plugins/jqgrid/jqgrid.css" rel="stylesheet" />
    <link rel="Shortcut icon" href="../images/favicon.ico" />
    <link href="../Content/styles/learun-ui.css" rel="stylesheet" />
    <link href="../css/my.css" rel="stylesheet" media="screen">
    <script src="../Content/scripts/plugins/dialog/dialog.js"></script>
    <script src="../Content/adminLTE/index.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/grid.locale-cn.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/jqgrid.min.js"></script>
    <script src="../Content/scripts/utils/learun-ui.js"></script>
    <script src="../Content/scripts/utils/learun-form.js"></script>

    <script>
        $(function () {
            var n = 1;
            if ($('#areascontent').height() > $(window).height() - 20) {
                $('#areascontent').css("margin-right", "0px");
            }
            $('#areascontent').height($(window).height()-106);
            var areaheight = $("#areascontent").height();
            $(window).resize(function (e) {
                window.setTimeout(function () {
                    $('#gridTable').setGridWidth(($('.gridPanel').width()));
                    $('#areascontent').height($(window).height()-106);
                }, 200);
            });

            $("#btn_Search").click(function () {
                if (!$("#content").hasClass("active")) {
                    $("#content").addClass("active")

                } else {
                    $("#content").removeClass("active")

                }
            });

            GetGrid();
            CreateSelect();
        });

        //加载表格
        function GetGrid() {
            var selectedRowIndex = 0;
            var $gridTable = $('#gridTable');
            $gridTable.jqGrid({
                url: "hs/GetEquMaintenceStandard.ashx",
                datatype: "json",
                height: $('#areascontent').height() -200,
                colModel: [
                    { label: '主键', name: 'ID', hidden: true },
                    {
                        label: '工序名称', name: 'ProcessName', index: 'ProcessName', width: 200, align: 'left', sortable: false
                    },
                    { label: '设备名称', name: 'DeviceName', index: 'DeviceName', width: 300, align: 'left', sortable: false },
                    { label: '保养规范编号', name: 'PmSpecCode', index: 'PmSpecCode', width: 200, align: 'left', sortable: false },

                    { label: '保养规范名称', name: 'PmSpecName', index: 'PmSpecName', width: 300, align: 'left', sortable: false },
                    { label: '保养类型', name: 'PmLevel', index: 'PmLevel', width: 200, align: 'left', sortable: false },
                    { label: '保养规范', name: 'PmSpecFile', hidden: true },
                    {
                        label: '保养规范', name: '', index: '', width: 250, align: 'center', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            return '<span onclick=\"btn_look(\'' + rowObject[0] + '\',\'' + rowObject[6] + '\')\" class=\"label label-success\" style=\"cursor: pointer;\"><i class="fa fa-eye"></i>查看</span>' + '<span onclick=\"btn_download(\'' + rowObject[0] + '\',\'' + rowObject[6] + '\')\" class=\"label label-success\" style=\"cursor: pointer;margin-left:10px;\"><i class="fa fa-download"></i>下载</span>';
                        }
                    },
                   
                    {
                        label: '操作', name: '', index: '', width: 300, align: 'center', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            return '<span onclick=\"btn_search(\'' + rowObject[0] + '\')\" class=\"label label-success\" style=\"cursor: pointer;\"><i class="fa fa-eye"></i>查看</span>' + '<span onclick=\"btn_edit(\'' + rowObject[0] + '\')\" class=\"label label-success\" style=\"cursor: pointer;margin-left:10px;\"><i class="fa fa-edit"></i>修改</span>' + '<span onclick=\"btn_delete(\'' + rowObject[0] + '\')\" class=\"label label-success\" style=\"cursor: pointer;margin-left:10px;\"><i class="fa fa-trash-o"></i>删除</span>';
                        }
                    },
                ],
                viewrecords: true,
                rowNum: 30,
                rowList: [30, 50, 100],
                pager: "#gridPager",
                sortname: 'PmSpecCode asc',
                rownumbers: true,
                shrinkToFit: false,
                autowidth: true,
                scrollrows: true,
                gridview: true,
                onSelectRow: function () {
                    selectedRowIndex = $("#" + this.id).getGridParam('selrow');
                    
                },
                gridComplete: function () {
                    $("#" + this.id).setSelection(selectedRowIndex, false);

                }
            });

            //查询事件
            $("#lr_btn_querySearch").click(function () {
                var processName = $("#ProcessName").val();
                var deviceName = $("#DeviceName").val();
                var pmSpecCode = $("#PmSpecCode").val();
                var pmSpecName = $("#PmSpecName").val();
                var pmLevel = $("#PmLevel").val();

                $gridTable.jqGrid('setGridParam', {
                    postData: { ProcessName: processName, DeviceName: deviceName, PmSpecCode: pmSpecCode, PmSpecName: pmSpecName, PmLevel: pmLevel }, page: 1
                }).trigger('reloadGrid');

            });
            //查询回车
            //$('#orderno').bind('keypress', function (event) {
            //    if (event.keyCode == "13") {
            //        $('#btn_Search').trigger("click");
            //    }
            //});
            $("#ProcessName").change(function () {
                $("#lr_btn_querySearch").trigger("click");
            });
        }

        //构造select
        function CreateSelect() {
            $("#ProcessName").empty();
            $("#PmSpecCode").empty();
            var optionstring = "";
            var optionstring1 = "";
            $.ajax({
                url: "EquDeviceInfo.aspx/GetProcessInfo",
                type: "post",
                dataType: "json",
                data: "{deviceid:''}",
                contentType: "application/json;charset=utf-8",
                success: function (data) {
                    var data1 = eval('(' + data.d + ')');
                    var i = 0;
                    for (i in data1) {
                        optionstring += "<option value=\"" + data1[i].ProcessName + "\" >" + data1[i].ProcessName.trim() + "</option>";
                    }
                    $("#ProcessName").html("<option value=''>请选择...</option> " + optionstring);
                },
                error: function (msg) {
                    dialogMsg("数据访问异常", -1);
                }
            });

            $.ajax({
                url: "EquDeviceInfo.aspx/GetPmSpecName",
                type: "post",
                dataType: "json",
                data: "{deviceid:''}",
                contentType: "application/json;charset=utf-8",
                success: function (data) {
                    var data1 = eval('(' + data.d + ')');
                    var i = 0;
                    for (i in data1) {
                        optionstring1 += "<option value=\"" + data1[i].PmSpecCode + "\" >" + data1[i].PmSpecCode.trim() + "</option>";
                    }
                    $("#PmSpecCode").html("<option value=''>请选择...</option> " + optionstring1);
                },
                error: function (msg) {
                    dialogMsg("数据访问异常", -1);
                }
            });
        }

        //新建设备保养规范
        function btn_Add(event) {
            dialogOpen({
                id: "Form",
                title: '设备保养规范信息维护--新增',
                url: '../Equipment/EquMaintenceStandradEdit.aspx?actionname=0',
                width: "750px",
                height: "500px",
                async: false,
                callBack: function (iframeId) {
                    top.frames[iframeId].AcceptClick($("#gridTable"));
                }
            });
        }

        //查看设备保养规范  1:查看
        function btn_search(equid) {
            if (equid == undefined) {
                equid = $("#gridTable").jqGridRowValue("ID");
            }
            
            dialogOpen({
                id: "Form",
                title: '设备保养规范信息维护--查看',
                url: '../Equipment/EquMaintenceStandradEdit.aspx?actionname=1&equid=' + equid + '',
                width: "750px",
                height: "500px",
                btn: null
            });
        }

        //编辑设备保养规范  2：编辑
        function btn_edit(equid) {
            if (equid == undefined) {
                equid = $("#gridTable").jqGridRowValue("ID");
            }
            dialogOpen({
                id: "Form",
                title: '设备保养规范信息维护--修改',
                url: '../Equipment/EquMaintenceStandradEdit.aspx?actionname=2&equid=' + equid + '',
                width: "750px",
                height: "500px",
                callBack: function (iframeId) {
                    top.frames[iframeId].AcceptClick($("#gridTable"));
                }
            });
        }

        //删除设备保养规范
        function btn_delete(equid) {
            if (equid == undefined) {
                equid = $("#gridTable").jqGridRowValue("ID");
            }
            dialogConfirm("注：您确定要删除吗？该操作将无法恢复", function (r) {
                if (r) {
                    Loading(true, "正在删除数据...");
                    window.setTimeout(function () {
                        $.ajax({
                            url: "EquMaintenceStandard.aspx/DeleteMaintenceStandard",
                            data: "{EquID:'" + equid + "'}",
                            type: "post",
                            dataType: "json",
                            contentType: "application/json;charset=utf-8",
                            success: function (data) {
                                if (data.d == "success") {
                                    Loading(false);
                                    dialogMsg("删除成功", 1);
                                    $("#gridTable").trigger("reloadGrid");
                                }
                                else if (data.d == "falut") {
                                    dialogMsg("删除失败", -1);
                                }
                            },
                            error: function (XMLHttpRequest, textStatus, errorThrown) {
                                Loading(false);
                                dialogMsg(errorThrown, -1);
                            },
                            beforeSend: function () {
                                Loading(true, "正在删除数据");
                            },
                            complete: function () {
                                Loading(false);
                            }
                        });
                    }, 500);
                }
            });
        }

        //查看保养规范
        function btn_look(objID, filepath) {
            if (objID == undefined) {
                objID = $("#gridTable").jqGridRowValue("ID");
                filepath = $("#gridTable").jqGridRowValue("PmSpecFile");
            }
            if (filepath == "") {
                dialogMsg("您还没有上传文档", 0);
                return false;
            }
            //window.open("../Equipment/hs/GetEquMaintenceStandardCRUD.ashx?Action=StandardFileCHECK&objID=" + objID);
            $.ajax({
                url: "../Equipment/hs/GetEquMaintenceStandardCRUD.ashx",
                data: { "Action": "StandardFileCHECK", "objID": objID },
                type: "post",
                datatype: "json",
                success: function (result) {
                    if (result != "false") {
                        dialogOpen({
                            id: "UploadifyForm",
                            title: '查看保养规范',
                            //contentType: "application/x-www-form-urlencoded; charset=UTF-8",
                            url: '../Equipment/FileSearchDialog.aspx?folderId=' + result,
                            width: "800px",
                            height: "800px",
                            btn: null
                        });
                    }
                    else {
                        dialogMsg("未能找到文件", -1);
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    Loading(false);
                    dialogMsg(errorThrown, -1);
                },
                complete: function () {
                    Loading(false);
                }
            });

        }

        //下载保养规范
        function btn_download(objID, filepath) {
            if (objID == undefined) {
                objID = $("#gridTable").jqGridRowValue("ID");
                filepath = $("#gridTable").jqGridRowValue("PmSpecFile");
            }
            if (filepath == "") {
                dialogMsg("您还没有上传文档", 0);
                return false;
            }
            window.open("../Equipment/hs/GetEquMaintenceStandardCRUD.ashx?Action=StandardFileDOWNLOAD&objID=" + objID);
        }
    </script>
</head>
<body data-spy="scroll" data-target=".navbar-example" id="body">
    <!--nav-->
    <div class="navbar navbar-inverse navbar-fixed-top" id="nav">
        
    </div>
    <!--end nav-->
   
    <!--导航栏-->
    <div class="yn jz container-fluid nav-bgn m0" id="menu_wrap">
      
    </div>
    <!--主体-->
    <div id="areascontent" style="margin:50px 10px 0 10px; margin-bottom: 0px; overflow: auto;">
         <div class="rows" style="margin-top:0.5%; margin-bottom: 0.8%; overflow: hidden;">
            <div style="float: left; width: 100%;">
                <div style="height:20%; border: 1px solid #e6e6e6; background-color: #fff;">
                    <div class="panel panel-default">
                        <div class="panel-heading"><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px;">设备保养规范管理</strong></div>
                          <div class="lr-layout-tool">
                               <div class="lr-layout-tool-left">
                                   <div class="lr-layout-tool-item">
                                       <span class="formTitle">工序名称：</span>
                                        <select class="form-control" id="ProcessName"></select>
                                   </div>
                                   <div class="lr-layout-tool-item" id="multiple_condition_query_item">
                                        <div id="multiple_condition_query" class="lr-query-wrap">
                                            <div class="lr-query-btn" id="btn_Search" style="font-size:10px;">
                                                <i class="fa fa-search"></i>&nbsp;多条件查询
                                            </div>
                                            <div class="lr-query-content" style="width:400px;height:220px;" id="content">
                                                <div class="lr-query-formcontent" style="display:block"></div>
                                                <div class="lr-query-arrow">
                                                    <div class="lr-query-inside"></div>
                                                </div>
                                                <div class="lr-query-content-bottom">
                                                     <%--<a id="lr_btn_queryReset" class="btn btn-default">&nbsp;重&nbsp;&nbsp;置</a>--%>
                                                     <a id="lr_btn_querySearch" class="btn btn-primary">&nbsp;查&nbsp;&nbsp;询</a>
                                                </div>
                                                 <div class=" col-xs-12 lr-form-item">                                                    <div class="lr-form-item-title" style="width:120px;">设备名称：</div>                                                    <input type="text" class="form-control" id="DeviceName" placeholder="请输入设备名称" style="margin-left:30px;">                                                </div>                                                <div class=" col-xs-12 lr-form-item">                                                    <div class="lr-form-item-title" style="width:120px;">保养规范编号：</div>                                                    <select class="form-control" id="PmSpecCode" style="margin-left:30px;"></select>                                                </div>
                                                <div class=" col-xs-12 lr-form-item">                                                    <div class="lr-form-item-title" style="width:120px;">保养规范名称：</div>                                                    <input type="text" class="form-control" id="PmSpecName" placeholder="请输入保养规范名称" style="margin-left:30px;">                                                </div>
                                                <div class=" col-xs-12 lr-form-item">                                                    <div class="lr-form-item-title" style="width:120px;">保养类型：</div>                                                    <select class="form-control" id="PmLevel" style="margin-left:30px;">
                                                        <option value=''>请选择...</option>
                                                        <option value='一级保养'>一级保养</option>
                                                        <option value='二级保养'>二级保养</option>
                                                    </select>                                                </div>
                                            </div>
                                        </div>
                                   </div>
                                </div>
                                <div class=" lr-layout-tool-right">
                                     <div class="btn-group">
                                         <a id="btn_Add" class="btn btn-default" onclick="btn_Add(event)"><i class="fa fa-plus"></i>&nbsp;新建</a>  
                                     </div>
                                 </div>
                           </div>
                       
                    </div>
                </div>
            </div>
        </div>

         <div class="rows" style="margin-top:3.5%; overflow: hidden; ">
             
              <div class="gridPanel">
                   <table id="gridTable"></table>
                   <div id="gridPager"></div>
              </div>
         </div>
    </div>

</body>
</html>

