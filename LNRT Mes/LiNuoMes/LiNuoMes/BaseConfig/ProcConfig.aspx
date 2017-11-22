<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ProcConfig.aspx.cs" Inherits="LiNuoMes.BaseConfig.ProcConfig" %>

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

            listOptions();
            InitPage();
        });

        //加载表格
        function InitPage() {
            var strBtnStyle = "cursor:pointer;margin-left:5px;font-weight:700;padding:.2em .6em .3em;font-size:14px;";
            var selectedRowIndex = 0;
            var $gridTable = $('#gridTable');
            $gridTable.jqGrid({
                url: "GetSetBaseConfig.ashx",
                postData: { Action: "MES_PROC_CONFIG_LIST" },
                datatype: "json",
                height: $('#areascontent').height() -190,
                rowNum: -1,
                jsonReader: {
                    repeatitems: false,   //此两个参数影响了是否刷新之后高亮选中记录: 如果直接设定为true, 则无论id项设定与否都可以实现高亮选中
                    id: "ID"              //此两个参数影响了是否刷新之后高亮选中记录: 需要设定为唯一字段即可,如果设定为0值, 则需要repeatitems为true才可以.
                },
                colModel: [
                    { label: 'ID',      name: 'ID', hidden: true },
                    { label: '序号', name: 'InturnNumber', index: 'InturnNumber', width: 50, align: 'center', sortable: false },
                    { label: '工序编号', name: 'ProcessCode', index: 'ProcessCode', width: 80, align: 'center', sortable: false },
                    { label: '工序名称', name: 'ProcessName', index: 'ProcessName', width: 150, align: 'left', sortable: false },
                    { label: '工序简介', name: 'ProcessDsca', index: 'ProcessDsca', width: 150, align: 'left', sortable: false },
                    { label: '工序节拍', name: 'ProcessBeat', index: 'ProcessBeat', width: 80, align: 'center', sortable: false },
                    { label: '在产工单', name: 'WorkOrderNumber', index: 'WorkOrderNumber', width: 100, align: 'center', sortable: false },
                    {
                        label: '在产工单类型', name: 'WorkOrderVersion', index: 'WorkOrderVersion', width: 120, align: 'center', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            return    cellvalue == "0" ? "正常订单"
                                    : cellvalue >= "1" ? "下线补单"
                                    : "";
                        }
                    },
                    { label: '待产工单', name: 'NextWorkOrderNumber', index: 'NextWorkOrderNumber', width: 100, align: 'center', sortable: false },
                    {
                        label: '待产工单类型', name: 'NextWorkOrderVersion', index: 'NextWorkOrderVersion', width: 120, align: 'center', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            return  cellvalue == "0" ? "正常订单"
                                  : cellvalue >= "1" ? "下线补单"
                                  : "";
                        }
                    },
                    { label: 'ReservedFlag', name: 'ReservedFlag', hidden: true, sortable: false },
                    {
                        label: '操作规范', width: 160, align: 'center', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            return '<button onclick=\"btn_ManCheck(     \'' + rowObject.ID + '\')\" class=\"btn btn-success\" style=\"' + strBtnStyle + '"><i class="fa fa-check-square-o"></i>&nbsp;查看</button>'
                                 + '<button onclick=\"btn_ManDownLoad(  \'' + rowObject.ID + '\')\" class=\"btn btn-success\" style=\"' + strBtnStyle + '"><i class="fa fa-download"></i>&nbsp;下载</button>';
                        }
                    },
                    {
                        label: '工单设定', width: 270, align: 'center', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            return '<button onclick=\"setWoDlg(\'CURR\', \'' + rowObject.ID + '\')\" class=\"btn btn-success\" style=\"' + strBtnStyle + '"><i class="fa fa-flag"></i>&nbsp;在产工单设定</button>'
                                 + '<button onclick=\"setWoDlg(\'NEXT\', \'' + rowObject.ID + '\')\" class=\"btn btn-success\" style=\"' + strBtnStyle + '"><i class="fa fa-edit"></i>&nbsp;待产工单设定</button>';
                        }
                    },
                    {
                        label: '操 作', width: 240, align: 'center', sortable: false,
                    formatter: function (cellvalue, options, rowObject) {
                        var dFlag = rowObject.ReservedFlag == "1" ? "disabled" : "";
                        return '<button onclick=\"showdlg(\'CHECK\', \'' + rowObject.ID + '\')\" class=\"btn btn-success\" style=\"' + strBtnStyle + '"><i class="fa fa-check-square-o"></i>&nbsp;查看</button>'
                              + '<button onclick=\"showdlg(\'EDIT\',  \'' + rowObject.ID + '\')\" class=\"btn btn-success\" style=\"' + strBtnStyle + '"><i class="fa fa-edit"></i>&nbsp;修改</button>'
                              + '<button ' + dFlag + ' onclick=\"btn_delete(\'' + rowObject.ID + '\')\" class=\"btn btn-danger\"  style=\"' + strBtnStyle + '"><i class="fa fa-trash"></i>&nbsp;删除</button>';
                       }
                    },
                ],
                shrinkToFit: false,
                autowidth: true,
                scrollrows: true,
                gridview: true,
                viewsortcols:[false, false, false],
                onSelectRow: function () {
                    selectedRowIndex = $("#" + this.id).getGridParam('selrow');
                },
                gridComplete: function () {
                    $("#" + this.id).setSelection(selectedRowIndex, false);
                }
            });

            //查询事件
            $("#btn_Search").click(function () {
                var ProcessCode = $("#ProcessCode").val();
                var ProcessName = $("#ProcessName").val();
                $gridTable.jqGrid('setGridParam', {
                    postData: {
                        ProcessCode: ProcessCode,
                        ProcessName: ProcessName
                    }
                }).trigger('reloadGrid');
            });

            //查询回车
            $('#ProcessName').bind('keypress', function (event) {
                if (event.keyCode == "13") {
                    $('#btn_Search').trigger("click");
                }
            });

            $('#ProcessCode').bind('change', function (event) {
                $('#btn_Search').trigger("click");
            });
        }

        function listOptions() {
            var strListOptions = "";
            $.ajax({
                url: "GetSetBaseConfig.ashx",
                data: { Action: "MES_PROC_CONFIG_LIST" },
                type: "post",
                datatype: "json",
                success: function (data) {
                    data = JSON.parse(data);
                    for (i in data) {
                        strListOptions += "<option value=\"" + data[i].ProcessCode + "\" >" + data[i].ProcessCode + "</option>";
                    }
                    $("#ProcessCode").html("<option value=''>请选择...</option> " + strListOptions);
                },
                error: function (msg) {
                    alert(msg.responseText);
                }
            });
        }

        function btn_ManCheck(objID) {
            window.open("./GetSetBaseConfig.ashx?Action=MES_PROC_CONFIG_CHECK&objID=" + objID);
        }


        function btn_ManDownLoad(objID) {
            //时间关系, 这里取和"查看"几乎是一样的动作.
            window.open("./GetSetBaseConfig.ashx?Action=MES_PROC_CONFIG_DOWNLOAD&objID=" + objID);
        }

        //新建
        function btn_Add(event) {
            var isSuccess = 0;
            showdlg('ADD', 0);
            if (isSuccess == 0) {
                $("#gridTable").trigger("reloadGrid");
            }
        }

        function setWoDlg(OPtype, ProcId) {

            var sTitle;
            if (     OPtype == "CURR") {
                sTitle = "工序在产工单设定";
            }
            else if (OPtype == "NEXT") {
                sTitle = "工序待产工单设定";
            }
            else if (OPtype == "CURRALL") {
                sTitle = "在产工单全部设定";
                ProcId = "-1";
            }
            else if (OPtype == "NEXTALL") {
                sTitle = "待产工单全部设定";
                ProcId = "-1";
            }
            dialogOpen({
                id: "Form",
                title: sTitle,
                url: "../Mfg/ProcessListWorkOrderEdit.aspx?OPtype=" + OPtype + "&ProcId=" + ProcId,
                width: "960px",
                height: "600px",
                callBack: function (iframeId) {
                    top.frames[iframeId].AcceptClick($("#gridTable"));
                }
            });
        }


        //编辑信息
        function showdlg(OPtype, ProcId) {
            if (ProcId == undefined) {
                ProcId = $("#gridTable").getRowData(selectedRowIndex)["ID"];
            }

            if (OPtype == undefined) {
                OPtype = "CHECK";
            }

            var sTitle = "";
            if (OPtype == "CHECK") {
                sTitle = "查看工序信息";
            }
            else if (OPtype == "EDIT") {
                sTitle = "修改工序信息";
            }
            else if (OPtype == "ADD") {
                sTitle = "新增工序信息";
            }

            dialogOpen({
                id: "Form",
                title: sTitle,
                url: "ProcConfigDetailEdit.aspx?OPtype=" + OPtype + "&ProcId=" + ProcId,
                width: "600px",
                height: "480px",
                callBack: function (iframeId) {
                    top.frames[iframeId].AcceptClick($("#gridTable"));
                }
            });
        }

        //删除信息
        function btn_delete(ProcId) {
            if (ProcId == undefined) {
                ProcId = $("#gridTable").getRowData(selectedRowIndex)["ID"];
            }
            var ReservedFlag = $("#gridTable").getRowData(ProcId)["ReservedFlag"];
            if (ReservedFlag == "1") {
                dialogMsg("此条记录是MES系统保留数据, 不可以删除!", -1);
                return;
            }


            dialogConfirm("注：您确定要删除吗？该操作将无法恢复", function (r) {
                if (r) {
                    Loading(true, "正在删除数据...");
                    window.setTimeout(function () {
                        $.ajax({
                            url: "GetSetBaseConfig.ashx",
                            data: {
                                Action: "MES_PROC_CONFIG_DEL",
                                ProcId: ProcId
                            },
                            type: "post",
                            datatype: "json",
                            success: function (data) {
                                data = JSON.parse(data);
                                if (data.result == "success") {
                                    Loading(false);
                                    dialogMsg("删除成功", 1);
                                    $("#gridTable").trigger("reloadGrid");
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
   </script>
</head>
<body data-spy="scroll" data-target=".navbar-example" id="body1" class="body">

    <!--nav-->
    <div class="navbar navbar-inverse navbar-fixed-top" id="nav"></div>
    <!--end nav-->
   
    <!--导航栏-->
    <div class="yn jz container-fluid nav-bgn m0" id="menu_wrap"></div>

    <!--主体-->
    <div id="areascontent" style="margin:50px 10px 0px 10px; margin-bottom: 0px; overflow: auto;">
         <div class="rows" style="margin-top:0.5%; margin-bottom: 0.8%; overflow: hidden;">
            <div style="float: left; width: 100%;">
                <div style="height:20%; border: 1px solid #e6e6e6; background-color: #fff;">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <table id="panelheading" border="0" style="width:100%">
                                <tr>
                                    <th><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px;">工序信息管理</strong></th>
                                    <td></td>
                                </tr>
                            </table>
                        </div>
                        <div class="panel-body" style="text-align:left">
                            <table id="form1" class="form" border="0">
                                <tr>
                                    <td class="formTitle" style="width:100px">工序编号：</td>
                                    <td class="formValue" style="width:200px">
                                         <select class="form-control" id="ProcessCode"></select>
                                    </td>
                                    <td class="formTitle" style="width:120px">工序名称：</td>
                                    <td class="formValue" style="width:200px">
                                        <input type="text" class="form-control" id="ProcessName" placeholder="请输入工序名称">
                                    </td>
                                    <td class="formValue" style="text-align:right">                                            
                                        <a id="btn_Search" class="btn btn-primary"><i class="fa fa-search"></i>&nbsp;查询</a>  
                                        <a id="btn_Add" class="btn btn-primary" onclick="btn_Add(event)"><i class="fa fa-plus"></i>&nbsp;新建</a>
                                        <a id="btn_CurrAll" class="btn btn-primary" onclick="setWoDlg('CURRALL', -1)"><i class="fa fa-flag"></i>&nbsp;在产工单全部设定</a>
                                        <a id="btn_NextAll" class="btn btn-primary" onclick="setWoDlg('NEXTALL', -1)"><i class="fa fa-edit"></i>&nbsp;待产工单全部设定</a>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>

         <div class="rows" style="margin-top:0.5%; overflow: hidden; ">
              <div class="gridPanel">
                   <table id="gridTable"></table>
                   <div id="gridPager"></div>
              </div>
         </div>
    </div>

    <style>
        *{
            font-size:15px; 
        }
      
        @media screen and (max-width: 1400px) { 
           .formTitle {
               font-size:15px;
               width:200px;
           } 
           .form-control {
               font-size:15px;
               width:200px;
               height:30px;
           }
           .aa{
               width:200px;
               height:30px;
           }
           #form1{
               margin-left:0px;
           }
       } 
       @media screen and (min-width: 1400px) { 
           .formTitle {
               font-size:15px;
               width:200px;
           } 
           .form-control {
               font-size:15px;
               width:200px;
               height:30px;
           }
           .aa{
               width:200px;
               height:30px;
           }
           #form1{
               margin-left:0px;
           }
       } 
    </style>
    
</body>
</html>
