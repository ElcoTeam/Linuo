<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PlcSendSelectProcess.aspx.cs" Inherits="LiNuoMes.Mfg.PlcSendSelectProcess" %>

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
    <script type="text/javascript" src="../js/m.js" charset="gbk"></script>
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
    <link href="../Content/styles/learun-ui.css?v=xGgPBYcCVZtMx26lXm_bETZOl5nvwnNwIiq-fpPtywo1" rel="stylesheet" />
    <link href="../css/my.css" rel="stylesheet" media="screen">
    <link href="../css/iziModal.css" rel="stylesheet" />
    <script src="../Content/scripts/plugins/dialog/dialog.js"></script>
    <script src="../Content/adminLTE/index.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/grid.locale-cn.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/jqgrid.min.js"></script>
    <script src="../Content/scripts/utils/learun-ui.js"></script>
    <script src="../Content/scripts/utils/learun-form.js"></script>
    <script src="../js/iziModal.min.js"></script>
    <script>
        var GoodsCode;
        var WorkOrderNumber;
        var WorkOrderVersion;
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
            GoodsCode        = request("GoodsCode");
            WorkOrderNumber  = request("WorkOrderNumber");
            WorkOrderVersion = request("WorkOrderVersion");

            $("#GoodsCode").html("产品物料编码:" + GoodsCode);
            $("#WorkOrderNumber").html("订单编号:" + WorkOrderNumber)

            var nGridWidth = $('.gridPanel').width();
            var strBtnStyle = "cursor:pointer;margin-left:5px;font-weight:700;padding:.2em .6em .3em;font-size:14px;";
            var selectedRowIndex = 0;
            var $gridTable = $('#gridTable');
            $gridTable.jqGrid({
                //此处暂时借用此公共模块, 需要进一步和工单结合起来, 进一步完成验证, 防止参数误派发.
                url: "../BaseConfig/GetSetBaseConfig.ashx",
                postData: {
                    "Action": "MES_PROC_CONFIG_LIST",
                    "WorkOrderNumber": WorkOrderNumber,
                    "WorkOrderVersion": WorkOrderVersion
                },
                datatype: "json",
                height: $('#areascontent').height() * 0.70,
                rowNum: -1,
                jsonReader: {
                    repeatitems: false,   //此两个参数影响了是否刷新之后高亮选中记录: 如果直接设定为true, 则无论id项设定与否都可以实现高亮选中
                    id: "ID"              //此两个参数影响了是否刷新之后高亮选中记录: 需要设定为唯一字段即可,如果设定为0值, 则需要repeatitems为true才可以.
                },
                colModel: [
                    { label: 'ID',      name: 'ID', hidden: true },
                    { label: 'ReservedFlag', name: 'ReservedFlag', hidden: true },
                    { label: '序号', name: 'InturnNumber', index: 'InturnNumber', width: nGridWidth * 10 / 100, align: 'center', sortable: false },
                    { label: '工序编号', name: 'ProcessCode', index: 'ProcessCode', width: nGridWidth * 20 / 100, align: 'center', sortable: false },
                    { label: '工序名称', name: 'ProcessName', index: 'ProcessName', width: nGridWidth * 40 / 100, align: 'center', sortable: false },
                    {
                        label: '选择', width: nGridWidth * 30 / 100, align: 'center', sortable: false,
                    formatter: function (cellvalue, options, rowObject) {
                        //    var dFlag = rowObject.ReservedFlag == "1" ? "disabled" : "";
                        var dFlag = "";
                        return '<button ' + dFlag + ' onclick=\"onPLCSend(\'' + rowObject.ProcessCode + '\')\" class=\"btn btn-success\"  style=\"' + strBtnStyle + '"><i class="fa fa-arrow-right"></i>下一步</button>';
                        }
                    },
                ],
                shrinkToFit: true,
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
        }

        function onPLCSend(ProcessCode) {
            window.location.href = "./PLCSendOperate.aspx?GoodsCode=" + GoodsCode + "&ProcessCode=" + ProcessCode;
        }

        function onRT(event) {
            window.history.back();
        }

        function request(name) {
            var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
            var r = window.location.search.substr(1).match(reg);
            if (r != null) return unescape(r[2]); return null;
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
                                    <th><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px;">PLC参数派发工序选择</strong></th>
                                    <td></td>
                                </tr>
                            </table>
                        </div>
                        <div class="panel-body">
                            <table border="0" style="width:100%">
                                <tr>
                                    <td><span id="GoodsCode" class="formTitle"></span></td>                                        
                                    <td><span id="WorkOrderNumber" class="formTitle"></span></td>                                        
                                    <td style="text-align:right;margin-right:20px">                                           
                                        <a class="btn btn-primary" onclick="onRT(event)"><i class="fa fa-reply"></i>返回</a>
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
               width:350px;
               height: 30px;
               line-height: 40px;
               text-align:right;
           } 
           .form-control {
               font-size:15px;
               width:80px;
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
              font-size:20px;
              width:380px;
              height: 40px;
              line-height: 50px;
              text-align:right;
          } 
          .form-control {
               font-size:20px;
               width:80px;
               height:40px;
               margin-left:5px;
               margin-right:5px;
           }
           #form1{
               margin: 0px 0px 0px 150px;
           }
       } 
    </style>
    
</body>
</html>
