<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="GoodsConfig.aspx.cs" Inherits="LiNuoMes.BaseConfig.GoodsConfig" %>

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

            InitPage();
        });

        //加载表格
        function InitPage() {
            var selectedRowIndex = 0;
            var $gridTable = $('#gridTable');
            var tWidth = $('.gridPanel').width();
            $gridTable.jqGrid({
                url: "GetSetBaseConfig.ashx",
                postData: { Action: "MES_GOODS_CONFIG_LIST" },
                datatype: "json",
                height: $('#areascontent').height() *0.60,
                colModel: [
                    { label: 'ID',          name: 'ID', hidden: true },
                    { label: '序号', name: 'InturnNumber', index: 'InturnNumber', width: tWidth * 5 / 100, align: 'center', sortable: false },
                    { label: '产品物料编号', name: 'GoodsCode', index: 'GoodsCode', width: tWidth * 20 / 100, align: 'center', sortable: false },
                    { label: '长', name: 'DimLength', index: 'DimLength', width: tWidth * 5 / 100, align: 'center', sortable: false },
                    { label: '宽', name: 'DimWidth', index: 'DimWidth', width: tWidth * 5 / 100, align: 'center', sortable: false },
                    { label: '高', name: 'DimHeight', index: 'DimHeight', width: tWidth * 5 / 100, align: 'center', sortable: false },
                    { label: '单位生产耗时', name: 'UnitCostTime', index: 'UnitCostTime', width: tWidth * 5 / 100, align: 'center', sortable: false },
                    {
                        label: '物料拉动料号维护', name: 'PLCParameters', index: 'PLCParameters', width: tWidth * 15 / 100, align: 'center', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            return '<span onclick=\"btn_PlcPullCheck( \'' + rowObject.GoodsCode + '\')\" class=\"label label-success\" style=\"cursor: pointer;\"                 ><i class="fa fa-check-square-o"></i>查看</span>'
                                 + '<span onclick=\"btn_PlcPullEdit(  \'' + rowObject.GoodsCode + '\')\" class=\"label label-success\" style=\"cursor: pointer;margin-left:20px;\"><i class="fa fa-edit"></i>修改</span>';
                        }
                    },
                    {
                        label: 'PLC参数', name: 'PLCParameters', index: 'PLCParameters', width: tWidth * 15 / 100, align: 'center', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            return '<span onclick=\"btn_PLCCheck( \'' + rowObject.GoodsCode + '\')\" class=\"label label-success\" style=\"cursor: pointer;\"                 ><i class="fa fa-check-square-o"></i>查看</span>'
                                 + '<span onclick=\"btn_PLCEdit(  \'' + rowObject.GoodsCode + '\')\" class=\"label label-success\" style=\"cursor: pointer;margin-left:20px;\"><i class="fa fa-edit"></i>修改</span>';
                        }
                    },
                    {
                        label: '操 作', width: tWidth * 20 / 100, align: 'center', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            return '<span onclick=\"showdlg(\'CHECK\', \'' + rowObject.ID + '\')\" class=\"label label-success\" style=\"cursor: pointer;\"                 ><i class="fa fa-check-square-o" ></i>查看</span>'
                                 + '<span onclick=\"showdlg(\'EDIT\',  \'' + rowObject.ID + '\')\" class=\"label label-success\" style=\"cursor: pointer;margin-left:20px;\"><i class="fa fa-edit"></i>修改</span>'
                                 + '<span onclick=\"btn_delete(        \'' + rowObject.ID + '\')\" class=\"label label-danger\"  style=\"cursor: pointer;margin-left:20px;\"><i class="fa fa-trash"></i>删除</span>';
                        }
                    },
                ],
                shrinkToFit: true,
                autowidth: true,
                scrollrows: true,
                gridview: true,
                rowNum: -1,
                onSelectRow: function () {
                    selectedRowIndex = $("#" + this.id).getGridParam('selrow');
                },
                gridComplete: function () {
                    $("#" + this.id).setSelection(selectedRowIndex, false);
                }
            });

            //查询事件
            $("#btn_Search").click(function () {
                var GoodsCode = $("#GoodsCode").val();
                var DimLength = $("#DimLength").val();
                var DimHeight = $("#DimHeight").val();
                var DimWidth  = $("#DimWidth").val();
                $gridTable.jqGrid('setGridParam', {
                    postData: {
                        GoodsCode: GoodsCode,
                        DimLength: DimLength,
                        DimHeight: DimHeight,
                        DimWidth : DimWidth 
                    }
                }).trigger('reloadGrid');
            });

            //查询回车

            $('#GoodsCode,#DimLength,#DimHeight,#DimWidth').bind('keypress', function (event) {
                if (event.keyCode == "13") {
                    $('#btn_Search').trigger("click");
                }
            });
        }

        function btn_PlcPullCheck(GoodsCode) {
            window.location.href = "./PlcPullConfig.aspx?FMType=MAINTAIN&OPtype=CHECK&GoodsCode=" + GoodsCode;
        }

        function btn_PlcPullEdit(GoodsCode) {
            window.location.href = "./PlcPullConfig.aspx?FMType=MAINTAIN&OPtype=EDIT&GoodsCode=" + GoodsCode;
        }

        function btn_PLCCheck(GoodsCode) {
            window.location.href = "./PLCConfig.aspx?FMType=MAINTAIN&OPtype=CHECK&GoodsCode=" + GoodsCode;
        }

        function btn_PLCEdit(GoodsCode) {
            window.location.href = "./PLCConfig.aspx?FMType=MAINTAIN&OPtype=EDIT&GoodsCode=" + GoodsCode;
        }

        //新建
        function btn_Add(event) {
            var isSuccess = 0;
            showdlg('ADD', 0);
            if (isSuccess == 0) {
                $("#gridTable").trigger("reloadGrid");
            }
        }

        //编辑信息
        function showdlg(OPtype, GoodsId) {
            if (GoodsId == undefined) {
                GoodsId = $("#gridTable").jqGridRowValue("ID");
            }

            if (OPtype == undefined) {
                OPtype = "CHECK";
            }

            var sTitle = "";
            if (OPtype == "CHECK") {
                sTitle = "查看产品物料编码";
            }
            else if (OPtype == "EDIT") {
                sTitle = "修改产品物料编码";
            }
            else if (OPtype == "ADD") {
                sTitle = "新增产品物料编码";
            }

            dialogOpen({
                id: "Form",
                title: sTitle,
                url: "GoodsConfigDetailEdit.aspx?OPtype=" + OPtype + "&GoodsId=" + GoodsId,
                width: "600px",
                height: "480px",
                callBack: function (iframeId) {
                    top.frames[iframeId].AcceptClick($("#gridTable"));
                }
            });
        }

        //删除信息
        function btn_delete(GoodsId) {
            if (GoodsId == undefined) {
                GoodsId = $("#gridTable").jqGridRowValue("ID");
            }
            dialogConfirm("注：您确定要删除吗？该操作将无法恢复", function (r) {
                if (r) {
                    Loading(true, "正在删除数据...");
                    window.setTimeout(function () {
                        $.ajax({
                            url: "GetSetBaseConfig.ashx",
                            data: {
                                Action: "MES_GOODS_CONFIG_DEL",
                                GoodsId: GoodsId
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
                                    <th><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px;">产品物料编码管理</strong></th>
                                    <td></td>
                                </tr>
                            </table>
                        </div>
                        <div class="panel-body" style="text-align:left">
                            <table id="form1" class="form" border="0">
                                <tr>
                                    <th class="formTitle" style="width:320px;text-align:right">产品物料编号：</th>
                                    <td class="formValue" colspan="2">
                                        <input type="text" class="form-control" id="GoodsCode" placeholder="请输入产品物料编码">
                                    </td>
                                </tr>
                                <tr>
                                    <th class="formTitle" style="text-align:right">长：</th>
                                    <td class="formValue" colspan="2">
                                        <input type="text" class="form-control" id="DimLength" placeholder="长度">
                                    </td>
                                </tr>
                                <tr>

                                    <th class="formTitle" style="width:50px;text-align:right">宽：</th>
                                    <td class="formValue" colspan="2">
                                        <input type="text" class="form-control" id="DimWidth" placeholder="高度">
                                    </td>
                                 </tr>
                                 <tr>
                                   <th class="formTitle" style="width:50px;text-align:right">高：</th>
                                    <td class="formValue">
                                        <input type="text" class="form-control" id="DimHeight" placeholder="宽度">
                                    </td>
                                    <td class="formValue">                                           
                                        <a id="btn_Search" class="btn btn-primary"><i class="fa fa-search"></i>&nbsp;查询</a>  
                                        <a id="btn_Add" class="btn btn-primary" onclick="btn_Add(event)"><i class="fa fa-plus"></i>&nbsp;新建</a>
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
              font-size:30px;
              width:250px;
          } 
          .form-control {
               font-size:30px;
               width:400px;
               height:45px;
           }
           #form1{
               margin: 0px 0px 0px 150px;
           }
       } 
     </style>
    
</body>
</html>
