﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MaterialBkfResponse.aspx.cs" Inherits="LiNuoMes.Mfg.MaterialBkfResponse" %>


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
    <script src="../My97DatePicker/WdatePicker.js"></script>
  
    <script>
        $(function () {
            
            if ($('#areascontent').height() > $(window).height() - 20) {
                $('#areascontent').css("margin-right", "0px");
            }
            $('#areascontent').height($(window).height() - 106);
            var areaheight = $("#areascontent").height();
            $(window).resize(function (e) {
                window.setTimeout(function () {
                    $('#gridTable').setGridWidth(($('.gridPanel').width()));
                    $('#areascontent').height($(window).height() - 106);
                }, 200);
            });
          
            fnDate();
        });


        //加载表格
        function GetGrid() {
            var selectedRowIndex = 0;
            var $gridTable = $('#gridTable');
            var materialcode = $("#materialcode").val();
            var PullTimeStart = $("#PullTimeStart").val();
            var PullTimeEnd = $("#PullTimeEnd").val();

            $gridTable.jqGrid({
                url: "GetMaterialBkfInfo.ashx",
                datatype: "json",
                postData: {
                    Action: "MFG_WIP_BKF_RESPONSE_LIST",
                    materialcode: materialcode,
                    PullTimeStart: PullTimeStart,
                    PullTimeEnd: PullTimeEnd
                },
                height: $(window).height() - 300,
                colModel: [
                    { label: '主键', name: 'ID', hidden: true },
                    {
                        label: '物料编号', name: 'ItemNumber', index: 'ItemNumber', width: 150, align: 'left'
                    },
                    { label: '物料描述', name: 'ItemDsca', index: 'ItemDsca', width: 300, align: 'left' },
                    { label: '单位', name: 'UOM', index: 'UOM', width: 100, align: 'center', sortable: false },
                    { label: '申请数量', name: 'ApplyQty', index: 'ApplyQty', width: 100, align: 'center' },
                    { label: '申请人', name: 'ApplyUser', index: 'ApplyUser', width: 150, align: 'center', sortable: false },
                    { label: '申请时间', name: 'ApplyTime', index: 'ApplyTime', width: 300, align: 'center' },
                    { label: '响应数量', name: 'ActionQty', index: 'ActionQty', width: 100, align: 'center' },
                    { label: '响应人', name: 'ActionUser', index: 'ActionUser', width: 100, align: 'center' },
                    { label: '响应时间', name: 'ActionTime', index: 'ActionTime', width: 300, align: 'center' },
                    {
                        label: '发送情况', name: 'Status', index: 'Status', width: 100, align: 'center',
                        formatter: function (cellvalue, options, rowObject) {
                            if (cellvalue == 0) {
                                return '待响应';
                            }
                            else if (cellvalue == 1) {
                                return '待确认';
                            }
                            else if (cellvalue == 2) {
                                return '已完成';
                            }
                            else if (cellvalue == -2) {
                                return '已删除';
                            }
                            else if (cellvalue == 3) {
                                return '已打印';
                            }

                        }
                    },
                    {
                        label: '操作', name: 'Status', index: 'Status', width: 110, align: 'center',
                        formatter: function (cellvalue, options, rowObject) {
                            console.log(rowObject);
                            if (cellvalue == 0) {
                                return '<span onclick=\"btn_enabled(\'' + rowObject.ID + '\',\'' + rowObject.ItemNumber + '\',\'' + rowObject.ApplyQty + '\')\" class=\"label label-success\" style=\"cursor: pointer;\">响应</span>' +
                                       '<span onclick=\"btn_delete(\'' + rowObject.ID + '\')\" class=\"label label-danger\" style=\"cursor: pointer; margin-left:10px;\">删除</span>';
                            }
                           
                            else {
                                return '';
                            }
                        }
                    },
                ],
                viewrecords: true,
                rowNum: 50,
                rowList: [50, 100, 150],
                pager: "#gridPager",
                sortname: 'ItemNumber asc',
                rownumbers: true,
                rownumWidth: 50,
                shrinkToFit: false,
                autowidth: true,
                scrollrows: true,
                gridview: true,
                onSelectRow: function () {
                    selectedRowIndex = $("#" + this.id).getGridParam('selrow');
                }
                //gridComplete: function () {
                //    $("#" + this.id).setSelection(selectedRowIndex, false);
                //}
            });

            //查询事件
            $("#btn_Search").click(function () {
                //var orderno = $("#orderno").val();
                var materialCode = $("#materialcode").val();
                var PullTimeStart = $("#PullTimeStart").val();
                var PullTimeEnd = $("#PullTimeEnd").val();
               
                $gridTable.jqGrid('setGridParam', {
                    postData: {
                        materialcode: materialCode,
                        PullTimeStart: PullTimeStart,
                        PullTimeEnd: PullTimeEnd
                    }, page: 1
                }).trigger('reloadGrid');

            });

            $gridTable.jqGrid('setLabel', 'rn', '序号', {
                'text-align': 'center'
            });

        }

        //响应
        function btn_enabled(keyValue, ItemNumber, keyQty) {
            if (keyValue == undefined) {
                keyValue = $("#gridTable").jqGridRowValue("ID");
                //keyNumber = $("#gridTable").jqGridRowValue("ItemNumber");
                ItemNumber = $("#gridTable").jqGridRowValue("ItemNumber");
                keyQty = $("#gridTable").jqGridRowValue("Qty");
            }
            // 响应数量
            dialogOpen({
                id: "Form",
                title: '物料编号：' + ItemNumber,
                url: '../Mfg/MaterialBkfResponseEdit.aspx?id=' + keyValue + '&ItemNumber=' + ItemNumber + '&Qty=' + keyQty + '',
                width: "500px",
                height: "250px",
                callBack: function (iframeId) {
                    top.frames[iframeId].AcceptClick();
                }
            });
        }


        //删除
        function btn_delete(keyValue) {
            if (keyValue == undefined) {
                keyValue = $("#gridTable").jqGridRowValue("ID");
            }
            dialogConfirm("注：您确定要删除吗？该操作将无法恢复", function (r) {
                if (r) {
                    Loading(true, "正在删除数据...");
                    window.setTimeout(function () {
                        $.ajax({
                            url: "MaterialBkfResponse.aspx/DeleteMaterialInfo",
                            data: "{MaterialID:'" + keyValue + "'}",
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

        
        //初始化拉动时间
        function fnDate() {
            var xhr = null;
            if (window.XMLHttpRequest) {
                xhr = new window.XMLHttpRequest();
            } else { // ie
                xhr = new ActiveObject("Microsoft")
            }
            // 通过get的方式请求当前文件
            xhr.open("get", "/");
            xhr.send(null);
            // 监听请求状态变化
            xhr.onreadystatechange = function () {
                var time = null,
                    preDate = null,
                    curDate = null;
                if (xhr.readyState === 2) {
                    var seperator1 = "-";
                    // 获取请求头里的时间戳
                    time = xhr.getResponseHeader("Date");
                    //console.log(xhr.getAllResponseHeaders())
                    curDate = new Date(time);
                    preDate = new Date(curDate.getTime() - 24 * 60 * 60 * 1000);
                    var month = curDate.getMonth() + 1;
                    var premonth = preDate.getMonth() + 1;
                    var strDate = curDate.getDate();
                    var strDate1 = preDate.getDate();
                    if (month >= 1 && month <= 9) {
                        month = "0" + month;
                    }
                    if (strDate >= 0 && strDate <= 9) {
                        strDate = "0" + strDate;
                    }
                    var currentdate = curDate.getFullYear() + seperator1 + month + seperator1 + strDate;
                    var predate = preDate.getFullYear() + seperator1 + premonth + seperator1 + strDate1;
                    $("#PullTimeStart").val(predate);
                    $("#PullTimeEnd").val(currentdate);
                    GetGrid();
                }
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
                        <div class="panel-heading"><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px;">反冲料申请响应</strong></div>
                        <div class="lr-layout-tool">
                               <div class="lr-layout-tool-left">
                                   <div class="lr-layout-tool-item">
                                       <span class="formTitle">物料编号：</span>
                                       <input type="text" class="form-control" id="materialcode" placeholder="请输入物料编号">
                                       <span class="formTitle">申请时间：</span>
                                       <input id="PullTimeStart"  type="text" onFocus="WdatePicker({maxDate:'#F{$dp.$D(\'PullTimeEnd\')}'})" class="Wdate timeselect" />&nbsp;至&nbsp;
                                       <input id="PullTimeEnd"  type="text" onFocus="WdatePicker({minDate:'#F{$dp.$D(\'PullTimeStart\')}'})" class="Wdate timeselect" /> 
                                   </div>
                                   <div class="lr-layout-tool-item" id="multiple_condition_query_item">
                                        <div id="multiple_condition_query" class="lr-query-wrap">
                                            <div class="lr-query-btn" id="btn_Search" style="font-size:10px;">
                                                <i class="fa fa-search"></i>&nbsp;查询
                                            </div>
                                        </div>
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





