<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MubConfig.aspx.cs" Inherits="LiNuoMes.BaseConfig.MubConfig" %>

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
        var GoodsCode = "";
        var OPtype = "";           //操作类型: CHECK, EDIT
        $(function () {
            if ($('#areascontent').height() > $(window).height() - 20) {
                $('#areascontent').css("margin-right", "0px");
            }
            $('#areascontent').height($(window).height()-106);
            var areaheight = $("#areascontent").height();
            $(window).resize(function (e) {
                window.setTimeout(function () {
                    $('#gridTable').setGridWidth(($('.gridPanel').width()) - 1);
                    $('#areascontent').height($(window).height()-106);
                }, 200);
            });

            InitPage();
        });

        //加载表格
        function InitPage() {
            GoodsCode = request("GoodsCode");
            OPtype = request("OPtype");
            $("#GoodsCode").html(GoodsCode);
            if (OPtype == "CHECK") {
                $("#btn_OK").remove();
                $("#btn_UP").remove();
            }

            var selectedRowIndex = 0;
            var $gridTable = $('#gridTable');
            var tWidth = $('.gridPanel').width();
            $gridTable.jqGrid({
                url: "GetSetBaseConfig.ashx",
                postData: { Action: "MES_GOODS_CONFIG_LIST" },
                datatype: "json",
                height: $('#areascontent').height() - 170,
                width: tWidth - 1,
                colModel: [
                    { label: 'ID',  name: 'ID', hidden: true },
                    { label: '序号', name: 'InturnNumber', index: 'InturnNumber',  width: tWidth * 5 / 100,  align: 'center', sortable: false },
                    { label: '物料编码', name: 'ItemNumber', index: 'ItemNumber',   width: tWidth * 15 / 100, align: 'center', sortable: false },
                    { label: '物料描述', name: 'ItemDsca',   index: 'ItemDsca',     width: tWidth * 30 / 100, align: 'center', sortable: false },
                    { label: '工序编号', name: 'ProcessCode', index: 'ProcessCode', width: tWidth * 10 / 100, align: 'center', sortable: false },
                    { label: '工序描述', name: 'ProcessName', index: 'ProcessName', width: tWidth * 30 / 100, align: 'center', sortable: false },
                    { label: '工序用料占比(%)', name: 'MubPercent', index: 'MubPercent', width: tWidth * 15 / 100, align: 'center', sortable: false }
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
        }


        function onbtn_DL(event) {

        }

        function onbtn_UP(event) {
            if (OPtype == "CHECK") {
                onbtn_RT(null);
                return;
            }

            if (OPtype == "EDIT") {
                dialogOpen({
                    id: "UploadifyMubExcel",
                    title: '上传文件',
                    url: './UploadifyMubExcel.aspx',
                    width: "600px",
                    height: "180px",
                    callBack: function (iframeId) {
                        top.frames[iframeId].AcceptClick($("#UploadedFile"), $("#TargetFile"), GoodsCode);
                    }
                });
            }
        }

        function onbtn_OK(event) {
            if (OPtype == "CHECK") {
                onbtn_RT(null);
                return;
            }

            if (OPtype == "EDIT") {
                //onSaveParameters();
            }
        }

        function onbtn_RT(event) {
            window.history.back();
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
                                    <th><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px;">产品用料分布维护</strong></th>
                                    <td></td>
                                </tr>
                            </table>
                        </div>
                        <div class="panel-body" style="text-align:left">
                            <table border="0" style="width:100%">
                                <tr>
                                    <th class="formTitle">产品物料编码：<span id="GoodsCode" class="formTitle">Goods Code</span></th>
                                    <td class="formValue" style="text-align:right;padding-left:10px">
                                        <span id="UploadedFile" class="formTitle"></span>||||                                           
                                        <span id="TargetFile" class="formTitle"></span>                                           
                                        <a id="btn_UP" class="btn btn-primary" onclick="onbtn_UP(event)"><i class="fa fa-upload"></i>&nbsp;上传</a>  
                                        <a id="btn_DL" class="btn btn-primary" onclick="onbtn_DL(event)"><i class="fa fa-download"></i>&nbsp;下载</a>  
                                        <a id="btn_OK" class="btn btn-primary" onclick="onbtn_OK(event)"><i class="fa fa-check"></i>&nbsp;确认</a>  
                                        <a id="btn_RT" class="btn btn-primary" onclick="onbtn_RT(event)"><i class="fa fa-reply"></i>&nbsp;返回</a>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
         <div class="rows" style="overflow: hidden; ">
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
               width:400px;
               height: 30px;
               line-height: 40px;
               text-align:right;
           } 
           .form-control {
               font-size:15px;
               width:160px;
               height:30px;
               margin-left:5px;
               margin-right:5px;
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
               width:400px;
               height: 30px;
               line-height: 40px;
               text-align:right;
           } 
           .form-control {
               font-size:15px;
               width:160px;
               height:30px;
               margin-left:5px;
               margin-right:5px;
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
