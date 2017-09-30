<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MaterialPullMonitor.aspx.cs" Inherits="LiNuoMes.Mfg.MaterialPullMonitor" %>

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
        var selectedRowIndex = 0;
        $(function () {
            $('#areascontent').height($(window).height() - 120);
            $(window).resize(function (e) {
                window.setTimeout(function () {
                    $('#gridTable').setGridWidth(($('.gridPanel').width()));
                    $('#areascontent').height($(window).height() - 120);
                    $('#gridTable').setGridHeight($('#areascontent').height() - 180);
                }, 200);
            });
            InitPage();
        });

        //加载表格
        function InitPage() {
            var strBtnStyle = "cursor:pointer;margin-left:5px;font-weight:700;padding:.2em .6em .3em;font-size:14px;";
            var $gridTable = $('#gridTable');
            $gridTable.jqGrid({
                url: "GetSetMfg.ashx",
                postData: { Action: "MFG_PLC_PARAM_WO_LIST" },
                datatype: "json",
                height: $('#areascontent').height() - 180,
                rowNum: -1,
                jsonReader: {
                    repeatitems: false,   //此两个参数影响了是否刷新之后高亮选中记录: 如果直接设定为true, 则无论id项设定与否都可以实现高亮选中
                    id: "ID"              //此两个参数影响了是否刷新之后高亮选中记录: 需要设定为唯一字段即可,如果设定为0值, 则需要repeatitems为true才可以.
                },
                colModel: [
                    { label: 'ID', name: 'ID', hidden: true },
                    { label: '序号', name: 'InturnNumber', index: 'InturnNumber', width: 50, align: 'center', sortable: false},
                    { label: '工序编号', name: 'ProcessCode', index: 'ProcessCode', width: 60, align: 'center', sortable: false, hidden:true },
                    { label: '工序名称', name: 'ParamValue', index: 'ParamValue', width: 140, align: 'left', sortable: false },
                    { label: '拉动点',   name: 'ParamName', index: 'ParamName', width: 240, align: 'left', sortable: false },
                    { label: '拉动点描述',name: 'ParamDsca', index: 'ParamDsca', width: 280, align: 'left', sortable: false },
                    { label: '订单编号', name: 'WorkOrderNumber', index: 'WorkOrderNumber', width: 100, align: 'center', sortable: false },
                    { label: '订单类型', name: 'WorkOrderType', index: 'WorkOrderType', width: 80, align: 'center', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            return  cellvalue == "0" ? "正常订单"
                                  : cellvalue == "1" ? "下线补单"
                                  : "";
                        }
                    },
                    { label: '产品物料编码', name: 'GoodsCode', index: 'GoodsCode', width: 120, align: 'center', sortable: false },
                    { label: '产品物料描述', name: 'GoodsDsca', index: 'GoodsDsca', width: 350, align: 'left', sortable: false },
                    {
                        label: '操 作', width: 100, align: 'center', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            var ret = "";
                            ret += '<button onclick=\"showdlg(\'EDIT\',  \'' + rowObject.ID + '\')\" class=\"btn btn-success\" style=\"' + strBtnStyle + '"><i class="fa fa-edit"></i>修改</button>';
                            ret += '<button onclick=\"showdlg(\'TRIG\',  \'' + rowObject.ID + '\')\" class=\"btn btn-success\" style=\"' + strBtnStyle + '"><i class="fa fa-edit"></i>拉动</button>';
                            return ret;
                        }
                    },
                ],
                shrinkToFit: false,
                autowidth: true,
                scrollrows: true,
                gridview: true,
                viewsortcols: [false, false, false],
                onSelectRow: function () {
                    selectedRowIndex = $("#" + this.id).getGridParam('selrow');
                },
                gridComplete: function () {
                    $("#" + this.id).setSelection(selectedRowIndex, false);
                }
            });
        }

        //编辑信息
        function showdlg(OPtype, SelectedId) {

            var ParamId   = $("#gridTable").getRowData(SelectedId)["ID"];
            var ParamName = $("#gridTable").getRowData(SelectedId)["ParamName"];
            var ParamDsca = $("#gridTable").getRowData(SelectedId)["ParamDsca"];

            var sTitle;
            var sUrl;
            var sWidth;
            var sHeight;

            if (OPtype == "EDIT") {
                sTitle = "设定物料拉动订单";
                sUrl = "MaterialPullMointorEdit.aspx?ParamId=" + ParamId;
                sWidth = "960px";
                sHeight = "600px";
            }
            if (OPtype == "EDITALL") {
                sTitle = "所有工位统一设定物料拉动订单";
                sUrl = "MaterialPullMointorEdit.aspx?ParamId=-1";
                sWidth = "960px";
                sHeight = "600px";
            }
            else if (OPtype == "TRIG") {
                sTitle = "物料拉动手动触发";
                sUrl = "MaterialPullMonitorTrig.aspx?ParamName=" + ParamName + "&ParamDsca=" + encodeURI(encodeURI(ParamDsca));
                sWidth = "400px";
                sHeight = "150px";
            }

            dialogOpen({
                id: "Form",
                title: sTitle,
                url: sUrl,
                width: sWidth,
                height: sHeight,
                callBack: function (iframeId) {
                    top.frames[iframeId].AcceptClick($("#gridTable"));
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
                                    <th><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px;">物料拉动管理</strong></th>
                                    <td></td>
                                </tr>
                            </table>
                        </div>
                        <div class="panel-body" style="text-align:left">
                            <table id="form1" class="form" border="0">
                                <tr>
                                    <td class="formValue" style="text-align:right">                                            
                                        <a id="btn_SetAll" class="btn btn-primary" onclick="showdlg('EDITALL', -1)"><i class="fa fa-flag"></i>&nbsp;所有工位统一设定物料拉动订单</a>
                                    </td>
                                </tr>
                            </table>
                        </div>

                        <div class="panel-body" style="text-align:left">
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
