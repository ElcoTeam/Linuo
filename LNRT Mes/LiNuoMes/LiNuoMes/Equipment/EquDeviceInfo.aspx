<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EquDeviceInfo.aspx.cs" Inherits="LiNuoMes.Equipment.EquDeviceInfo" %>

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
            GetGrid();
            CreateSelect();
        });

        //加载表格
        function GetGrid() {
            var selectedRowIndex = 0;
            var $gridTable = $('#gridTable');
            $gridTable.jqGrid({
                url: "hs/GetEquDeviceInfo.ashx",
                datatype: "json",
                height: $('#areascontent').height() *0.7,
                colModel: [
                    { label: '主键', name: 'ID', hidden: true },
                    {
                        label: '设备编号', name: 'DeviceCode', index: 'DeviceCode', width: 200, align: 'left', sortable: false
                    },
                    { label: '设备名称', name: 'DeviceName', index: 'DeviceName', width: 300, align: 'left', sortable: false },
                    { label: '工序名称', name: 'ProcessName', index: 'ProcessName', width: 300, align: 'left', sortable: false },

                    { label: '硬件组成明细表', name: 'DevicePartsFile', index: 'DevicePartsFile', hidden: true },
                    { label: '设备操作说明书', name: 'DeviceManualFile', index: 'DeviceManualFile', hidden: true },

                    {
                        label: '硬件组成明细表', name: '', index: '', width: 250, align: 'center', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            return '<span onclick=\"btn_look(\'' + rowObject[0] + '\',\'' + rowObject[4] + '\')\" class=\"label label-success\" style=\"cursor: pointer;\"><i class="fa fa-eye"></i>查看</span>' + '<span onclick=\"btn_download(\'' + rowObject[0] + '\',\'' + rowObject[4] + '\')\" class=\"label label-success\" style=\"cursor: pointer;margin-left:10px;\"><i class="fa fa-download"></i>下载</span>';
                        }
                    },
                    {
                        label: '设备操作说明书', name: '', index: '', width: 250, align: 'center', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            return '<span onclick=\"btn_look1(\'' + rowObject[0] + '\',\'' + rowObject[5] + '\')\" class=\"label label-success\" style=\"cursor: pointer;\"><i class="fa fa-eye"></i>查看</span>' + '<span onclick=\"btn_download1(\'' + rowObject[0] + '\',\'' + rowObject[5] + '\')\" class=\"label label-success\" style=\"cursor: pointer;margin-left:10px;\"><i class="fa fa-download"></i>下载</span>';
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
                sortname: 'DeviceCode asc',
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
            $("#btn_Search").click(function () {
                var processName = $("#ProcessName").val();
                var deviceCode = $("#DeviceCode").val();
                var deviceName = $("#DeviceName").val();
                
                $gridTable.jqGrid('setGridParam', {
                    postData: { ProcessName: processName, DeviceCode: deviceCode, DeviceName: deviceName }, page: 1
                }).trigger('reloadGrid');

            });
            //查询回车
            //$('#orderno').bind('keypress', function (event) {
            //    if (event.keyCode == "13") {
            //        $('#btn_Search').trigger("click");
            //    }
            //});
        }

        //构造select
        function CreateSelect() {
            $("#ProcessName").empty();
            var optionstring = "";
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
                        optionstring += "<option value=\"" + data1[i].ProcessCode + "\" >" + data1[i].ProcessName.trim() + "</option>";
                        
                    }
                    $("#ProcessName").html("<option value=''>请选择...</option> " + optionstring);
                    
                },
                error: function (msg) {
                    dialogMsg("数据访问异常", -1);
                }
            });
           
        }

        //新建设备信息
        function btn_Add(event) {
            dialogOpen({
                id: "Form",
                title: '设备信息维护--新增',
                url: '../Equipment/EquInfoEdit.aspx?actionname=0',
                width: "750px",
                height: "500px",
                async: false,
                callBack: function (iframeId) {
                    top.frames[iframeId].AcceptClick($("#gridTable"));

                }
            });
        }

        //查看设备信息  1:查看
        function btn_search(equid) {
            if (equid == undefined) {
                equid = $("#gridTable").jqGridRowValue("ID");
            }
            dialogOpen({
                id: "Form",
                title: '设备信息维护--查看',
                url: '../Equipment/EquInfoEdit.aspx?actionname=1&equid=' + equid + '',
                width: "750px",
                height: "500px",
                btn: null
            });
        }

        //编辑设备信息  2：编辑
        function btn_edit(equid) {
            if (equid == undefined) {
                equid = $("#gridTable").jqGridRowValue("ID");
            }
            dialogOpen({
                id: "Form",
                title: '设备信息维护--修改',
                url: '../Equipment/EquInfoEdit.aspx?actionname=2&equid=' + equid + '',
                width: "750px",
                height: "500px",
                callBack: function (iframeId) {
                    top.frames[iframeId].AcceptClick($("#gridTable"));
                }
            });
        }
        //删除设备信息
        function btn_delete(equid) {
            if (equid == undefined) {
                equid = $("#gridTable").jqGridRowValue("ID");
            }
            dialogConfirm("注：您确定要删除吗？该操作将无法恢复", function (r) {
                if (r) {
                    Loading(true, "正在删除数据...");
                    window.setTimeout(function () {
                        $.ajax({
                            url: "EquDeviceInfo.aspx/DeleteEquInfo",
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

        //查看硬件组成
        function btn_look(objID, filepath) {
            if (objID == undefined) {
                objID = $("#gridTable").jqGridRowValue("ID");
                filepath = $("#gridTable").jqGridRowValue("DevicePartsFile");
            }
            if (filepath == "") {
                dialogMsg("您还没有上传文档", 0);
                return false;
            }
            window.open("../Equipment/hs/GetEquDeviceCRUD.ashx?Action=PartsFileCHECK&objID=" + objID);
        }

        //查看操作说明
        function btn_look1(objID, filepath) {
            if (objID == undefined) {
                objID = $("#gridTable").jqGridRowValue("ID");
                filepath = $("#gridTable").jqGridRowValue("DeviceManualFile");
            }
            if (filepath == "") {
                dialogMsg("您还没有上传文档", 0);
                return false;
            }
            window.open("../Equipment/hs/GetEquDeviceCRUD.ashx?Action=ManuCHECK&objID=" + objID);
        }

        //下载硬件组成
        function btn_download(objID, filepath) {
            if (objID == undefined) {
                objID = $("#gridTable").jqGridRowValue("ID");
                filepath = $("#gridTable").jqGridRowValue("DevicePartsFile");
            }
            if (filepath == "") {
                dialogMsg("您还没有上传文档", 0);
                return false;
            }
            window.open("../Equipment/hs/GetEquDeviceCRUD.ashx?Action=PartsFileDOWNLOAD&objID=" + objID);
            //postAndRedirect("../Equipment/hs/GetEquDeviceCRUD.ashx?Action=" + 'PartsFileDOWNLOAD', { objID: objID });
        }

        //下载操作说明
        function btn_download1(objID, filepath) {
            if (objID == undefined) {
                objID = $("#gridTable").jqGridRowValue("ID");
                filepath = $("#gridTable").jqGridRowValue("DeviceManualFile");
            }
            if (filepath == "") {
                dialogMsg("您还没有上传文档", 0);
                return false;
            }
            window.open("../Equipment/hs/GetEquDeviceCRUD.ashx?Action=ManuDOWNLOAD&objID=" + objID);
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
                        <div class="panel-heading"><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px;">设备信息管理</strong></div>
                        <div class="panel-body">
                            <table id="form1" class="form">
                                <tr>
                                    <th class="formTitle">工序名称：</th>
                                    <td class="formValue">
                                       <select class="form-control" id="ProcessName">
                                         </select>
                                    </td>
                                    <th class="formTitle">设备编号：</th>
                                    <td class="formValue">
                                        <input type="text" class="form-control" id="DeviceCode" placeholder="请输入设备编号">
                                    </td>
                                     <td class="formValue">
                                          <a id="btn_Search" class="btn btn-primary"><i class="fa fa-search"></i>&nbsp;查询</a>                        
                                         <a id="btn_Add" class="btn btn-primary" onclick="btn_Add(event)"><i class="fa fa-plus"></i>&nbsp;新建</a>  
                                     </td>
                                </tr>
                                <tr>
                                    <th class="formTitle">设备名称：</th>
                                    <td class="formValue">
                                        <input type="text" class="form-control" id="DeviceName" placeholder="请输入设备名称">
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

</body>
</html>
