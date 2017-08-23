<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ProcessPram.aspx.cs" Inherits="LiNuoMes.ProdutionMan.ProcessPram" %>

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
        });

        //加载表格
        function GetGrid() {
            var selectedRowIndex = 0;
            var $gridTable = $('#gridTable');
            $gridTable.jqGrid({
                url: "hs/GetQualityStandrad.ashx",
                datatype: "json",
                height: $('#areascontent').height() *0.7,
                colModel: [
                    { label: '主键', name: 'ID', hidden: true },
                    {
                        label: '工序', name: 'ProduceName', index: 'ProduceName', width: 200, align: 'left'
                    },
                    { label: '质量控制点', name: 'QualityControl', index: 'QualityControl', width: 500, align: 'left' },
                   
                    { label: '质量标准', name: 'QualityStandrad', index: 'QualityStandrad', width: 400, align: 'left' },
                    { label: '实际检测', name: 'ActualTest', index: 'ActualTest', width: 400, align: 'left' },
                    {
                        label: '是否合格', name: 'Qualified', index: 'Qualified', width: 200, align: 'center',
                        formatter: function (cellvalue, options, rowObject) {
                            if (cellvalue == 1) {
                                return '<span  class=\"label label-success\">合格</span>';
                            } else if (cellvalue == 0) {
                                return '<span  class=\"label label-warning\">不合格</span>';
                            } 
                        }
                    },
                ],
                viewrecords: true,
                rowNum: 30,
                rowList: [30, 50, 100],
                pager: "#gridPager",
                sortname: 'ID asc',
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
            //$("#btn_Search").click(function () {
            //    var orderno = $("#orderno").val();
            //    var materialCode = $("#materialcode").val();
            //    var produce = $("#produce").val();
            //    //var station = $("#station").val();
            //    $gridTable.jqGrid('setGridParam', {
            //        postData: { Orderno: orderno, MaterialCode: materialCode, Produce: produce}, page: 1
            //    }).trigger('reloadGrid');

            //});
            //查询回车
            //$('#btn_Search').bind('keypress', function (event) {
            //    if (event.keyCode == "13") {
            //        $('#btn_Search').trigger("click");
            //    }
            //});
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
                        <div class="panel-heading"><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i><strong style="font-size:30px;">完成品生产工艺参数</strong></div>
                        <div class="panel-body">
                            <table id="form1" class="form">
                                <tr>
                                    <th class="formTitle">订单编号：</th>
                                    <td class="formValue">
                                        <label id="order" class="form-control" style=" border: 0px;">20075002</label>
                                    </td>
                                    <th class="formTitle">MES码：</th>
                                    <td class="formValue">
                                        <label id="mesno" class="form-control" style=" border: 0px;">200750022017042001</label>
                                    </td>
                                </tr>
                                <tr>
                                    <th class="formTitle">产品物料编号：</th>
                                    <td class="formValue">
                                         <label id="item" class="form-control" style=" border: 0px;">1234567890</label>
                                    </td>
                                     <th class="formTitle">完成时间：</th>
                                    <td class="formValue">
                                         <label id="finishtime" class="form-control" style=" border: 0px;">2017/04/06</label>
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


