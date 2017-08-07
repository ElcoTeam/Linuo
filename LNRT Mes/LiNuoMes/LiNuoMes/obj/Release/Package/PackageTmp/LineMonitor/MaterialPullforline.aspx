<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MaterialPullforline.aspx.cs" Inherits="LiNuoMes.LineMonitor.MaterialPullforline" %>

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
                url: "hs/GetMaterialpullforline.ashx",
                datatype: "json",
                height: $('#areascontent').height() *0.7,
                colModel: [
                    { label: '主键', name: 'No', hidden: true },
                    {
                        label: '订单编号', name: 'OrderNo', index: 'OrderNo', width: 200, align: 'left'
                    },
                    { label: '工序名称', name: 'Procedure_Name', index: 'Procedure_Name', width: 200, align: 'left' },
                    //{ label: '工位名称', name: 'Station_Name', index: 'Station_Name', width: 200, align: 'left' },
                    { label: '物料编号', name: 'MaterialCode', index: 'MaterialCode', width: 200, align: 'left' },
                    { label: '拉动数量', name: 'Pull_Qty', index: 'Pull_Qty', width: 100, align: 'left' },
                    { label: '拉动时间', name: 'PullTime', index: 'PullTime', width: 150, align: 'left' },
                    { label: '响应时间', name: 'ResponseTime', index: 'ResponseTime', width: 100, align: 'left' },
                    { label: '确认时间', name: 'ConfirmTime', index: 'ConfirmTime', width: 150, align: 'left' },
                    { label: '响应人', name: 'ResponseOP', index: 'ResponseOP', width: 100, align: 'left' },
                    { label: '确认人', name: 'ConfirmOP', index: 'ConfirmOP', width: 100, align: 'left' },
                    {
                        label: '状态', name: 'PullState', index: 'PullState', width: 100, align: 'center',
                        formatter: function (cellvalue, options, rowObject) {
                            if (cellvalue == 1) {
                                return '<span  class=\"label label-success\">已确认</span>' + '<span onclick=\"btn_delete(\'' + rowObject[0] + '\')\" class=\"label label-danger\" style=\"cursor: pointer;margin-left:5px;\">删除</span>';
                            } else if (cellvalue == 0) {
                                return '<span onclick=\"btn_enabled(\'' + rowObject[0] + '\')\" class=\"label label-danger\" style=\"cursor: pointer;\">未确认</span>' + '<span onclick=\"btn_delete(\'' + rowObject[0] + '\')\" class=\"label label-danger\" style=\"cursor: pointer;margin-left:5px;\">删除</span>';
                            }
                        }
                    },
                ],
                viewrecords: true,
                rowNum: 30,
                rowList: [30, 50, 100],
                pager: "#gridPager",
                sortname: 'OrderNo asc',
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
                var orderno = $("#orderno").val();
                var materialCode = $("#materialcode").val();
                var produce = $("#produce").val();
                //var station = $("#station").val();
                $gridTable.jqGrid('setGridParam', {
                    postData: { Orderno: orderno, MaterialCode: materialCode, Produce: produce}, page: 1
                }).trigger('reloadGrid');

            });
            //查询回车
            $('#orderno').bind('keypress', function (event) {
                if (event.keyCode == "13") {
                    $('#btn_Search').trigger("click");
                }
            });
        }

        //构造select
        function CreateSelect() {
            $("#produce").empty();
           // $("#station").empty();
            var optionstring = "";
            //var optionstring1 = "";
            $.ajax({
                url: "MaterialPullforline.aspx/GetProduceInfo",   
                type: "post",
                dataType: "json",
                data: "{deviceid:''}",
                contentType: "application/json;charset=utf-8",
                success: function (data) {
                    var data1 = eval('(' + data.d + ')');
                    var i = 0;
                    for (i in data1) {
                        optionstring += "<option value=\"" + data1[i].Procedure_Name + "\" >" + data1[i].Procedure_Name.trim() + "</option>";
                        //optionstring1 += "<option value=\"" + data1[i].Station_Name + "\" >" + data1[i].Station_Name.trim() + "</option>";
                    }
                    $("#produce").html("<option value=''>请选择...</option> " + optionstring);
                    //$("#station").html("<option value=''>请选择...</option> " + optionstring1);
                    //$("#produce").dropkick();
                },
                error: function (msg) {
                    dialogMsg("数据访问异常", -1);
                }
            });
           
        }


        //确认
        function btn_enabled(keyValue) {
            if (keyValue == undefined) {
                keyValue = $("#gridTable").jqGridRowValue("No");
            }
            if (keyValue) {
                   Loading(true, "正在保存数据...");
                   window.setTimeout(function () {
                       $.ajax({
                           url: "MaterialPullforline.aspx/ConfirmPullInfo",
                           data: "{no:'" + keyValue + "'}",
                           type: "post",
                           dataType: "json",
                           contentType: "application/json;charset=utf-8",
                           success: function (data) {
                               if (data.d == "success") {
                                   Loading(false);
                                   dialogMsg("确认成功", 1);
                                   $("#gridTable").trigger("reloadGrid");
                               }
                               else if (data.d == "falut") {
                                   dialogMsg("确认失败", -1);
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
                   }, 500);           
            } else {
                dialogMsg('您没有选择任何数据！', 0);
            }
        }

        //删除
        function btn_delete(keyValue) {
            if (keyValue == undefined) {
                keyValue = $("#gridTable").jqGridRowValue("No");
            }
            //var keyValue = $("#gridTable").jqGridRowValue("No");
            if (keyValue) {
                dialogConfirm("注：您确定要删除吗？该操作将无法恢复", function (r) {
                    if (r) {
                        Loading(true, "正在删除数据...");
                        window.setTimeout(function () {
                            $.ajax({
                                url: "MaterialPullforline.aspx/DeletePullInfo",
                                data: "{no:'" + keyValue + "'}",
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
            } else {
                dialogMsg('您没有选择任何数据！', 0);
            }
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
                        <div class="panel-heading"><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i><strong style="font-size:30px;">物料拉动确认</strong></div>
                        <div class="panel-body">
                            <table id="form1" class="form">
                                <tr>
                                    <th class="formTitle">订单编号：</th>
                                    <td class="formValue">
                                        <%--<label id="currentgx" class="form-control" style=" border: 0px;">排管焊接</label>--%>
                                        <input type="text" class="form-control" id="orderno" placeholder="请输入订单编号">
                                    </td>
                                    <th class="formTitle">物料编号：</th>
                                    <td class="formValue">
                                        <input type="text" class="form-control" id="materialcode" placeholder="请输入物料编号">
                                    </td>
                                     <td class="formValue">
                                          <a id="btn_Search" class="btn btn-primary"><i class="fa fa-search"></i>&nbsp;查询</a>                        
                                         <%--<input id="btn_Search" type="button" value="查询" class="btn btn-primary"/>--%>
                                     </td>
                                </tr>
                                <tr>
                                    <th class="formTitle">工序名称：</th>
                                    <td class="formValue">
                                         <select class="form-control" id="produce">
                                         </select>
                                    </td>
                                    <%-- <th class="formTitle">工位名称：</th>
                                    <td class="formValue">
                                         <select class="form-control" id="station">
                                         </select>
                                    </td>--%>
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
        /*.formTitle {
            font-size:30px;
        }
        .form-control {
            font-size:30px;
        }*/
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
               width:300px;
               height:45px;
           }
           #form1{
               margin: 0px 0px 0px 150px;
           }
       } 
        #copyrightcontent {
            height: 30px;
            line-height: 29px;
            overflow: hidden;
            position: absolute;
            top: 100%;
            margin-top: -30px;
            width: 100%;
            background-color: #fff;
            border: 1px solid #e6e6e6;
            padding-left: 10px;
            padding-right: 10px;
        }

      

        .panel-default {
            border: none;
            border-radius: 0px;
            margin-bottom: 0px;
            box-shadow: none;
            -webkit-box-shadow: none;
        }

            .panel-default > .panel-heading {
                color: #777;
                background-color: #fff;
                border-color: #e6e6e6;
                padding: 10px 10px;
            }

            .panel-default > .panel-body {
                padding: 10px;
                padding-bottom: 0px;
                height:100%;
            }

                .panel-default > .panel-body ul {
                    overflow: hidden;
                    padding: 0;
                    margin: 0px;
                    margin-top: -5px;
                }

                    .panel-default > .panel-body ul li {
                        line-height: 27px;
                        list-style-type: none;
                        white-space: nowrap;
                        text-overflow: ellipsis;
                    }

                        .panel-default > .panel-body ul li .time {
                            color: #a1a1a1;
                            float: right;
                            padding-right: 5px;
                        }
          .pdfobject { border: 1px solid #fff; }
        
    </style>
   
</body>
</html>

