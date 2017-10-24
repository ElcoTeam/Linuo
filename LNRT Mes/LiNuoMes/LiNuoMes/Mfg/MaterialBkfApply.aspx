<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MaterialBkfApply.aspx.cs" Inherits="LiNuoMes.Mfg.MaterialBkfApply" %>
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
           
            //GetGrid();
            fndate();
        });

        //加载表格
        function GetGrid() {
            var selectedRowIndex = 0;
            var $gridTable = $('#gridTable');
            $gridTable.jqGrid({
                url: "./GetMaterialBkfInfo.ashx",
                datatype: "json",
                postData: {
                    "Action": "MFG_WIP_BKF_APPLY_LIST",
                    StartDate: $("#StartDate").val(),
                    FinishDate: $("#FinishDate").val()
                },
                height: $('#areascontent').height() - 200,
                colModel: [
                    { label: '主键', name: 'ID', hidden: true },
                    { label: '序号', name: 'InturnNumber', index: 'InturnNumber', width: 100, align: 'center', sortable: false },
                    { label: '物料编码', name: 'ItemNumber', index: 'ItemNumber', width: 200, align: 'center', sortable: false },
                    { label: '物料描述', name: 'ItemDsca', index: 'ItemDsca', width: 400, align: 'left', sortable: false },
                    { label: '数量', name: 'ApplyQty', index: 'ApplyQty', width: 200, align: 'center', sortable: false },
                    { label: '单位', name: 'UOM', index: 'UOM', width: 100, align: 'center', sortable: false },
                    { label: '申请人员', name: 'ApplyUser', index: 'ApplyUser', width: 250, align: 'center', sortable: false },
                    { label: '申请时间', name: 'ApplyTime', index: 'ApplyTime', width: 350, align: 'center', sortable: false },
                    {
                        label: '申请状态', name: 'Status', index: 'Status', width: 100, align: 'center', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            
                            return '待响应';
                        }
                    },
                ],
                viewrecords: true,
                rowNum: 30,
                rowList: [30, 50, 100],
                pager: "#gridPager",
                sortname: 'InturnNumber asc',
                rownumbers: false,
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
                var StartDate = $("#StartDate").val();
                var FinishDate = $("#FinishDate").val();
               
                $gridTable.jqGrid('setGridParam', {
                    postData: {
                        StartDate: StartDate,
                        FinishDate: FinishDate
                    }, page: 1
                }).trigger('reloadGrid');

            });
           
        }


        //反冲料申请 
        function btn_Apply(event)
        {
            dialogOpen({
                id: "Form",
                title: '新增反冲料申请',
                url: '../Mfg/MaterialBkfApplyAdd.aspx?',
                width: "1200px",
                height: "600px",
                callBack: function (iframeId) {
                    top.frames[iframeId].AcceptClick();
                }
            });
        }

        //设置默认时间选择
        function fndate() {
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
                    curDate = null;
                if (xhr.readyState === 2) {
                    var seperator1 = "-";
                    // 获取请求头里的时间戳
                    time = xhr.getResponseHeader("Date");
                    //console.log(xhr.getAllResponseHeaders())
                    curDate = new Date(time);
                    var oneweekdate = new Date(curDate.getTime() - 7 * 24 * 3600 * 1000);
                    //当前时间
                    var month = curDate.getMonth() + 1;
                    var strDate = curDate.getDate();
                    if (month >= 1 && month <= 9) {
                        month = "0" + month;
                    }
                    if (strDate >= 0 && strDate <= 9) {
                        strDate = "0" + strDate;
                    }
                    var currentdate = curDate.getFullYear() + seperator1 + month + seperator1 + strDate;
                    //一周前时间
                    var month = oneweekdate.getMonth() + 1;
                    var strDate = oneweekdate.getDate();
                    if (month >= 1 && month <= 9) {
                        month = "0" + month;
                    }
                    if (strDate >= 0 && strDate <= 9) {
                        strDate = "0" + strDate;
                    }
                    var oneweekagodate = oneweekdate.getFullYear() + seperator1 + month + seperator1 + strDate;
                    $("#FinishDate").val(currentdate);
                    $("#StartDate").val(oneweekagodate);
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
                        <div class="panel-heading"><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px;">反冲料申请</strong></div>
                        <div class="lr-layout-tool">
                               <div class="lr-layout-tool-left">
                               <div class="lr-layout-tool-item">
                                       <span class="formTitle">申请日期：</span>
                                       <input id="StartDate"  type="text" onFocus="WdatePicker({maxDate:'#F{$dp.$D(\'FinishDate\')}'})" class="Wdate timeselect" />&nbsp;至&nbsp;
                                       <input id="FinishDate"  type="text" onFocus="WdatePicker({minDate:'#F{$dp.$D(\'StartDate\')}'})" class="Wdate timeselect" />
                               </div>
                               <div class="lr-layout-tool-item" id="multiple_condition_query_item">
                                    <div id="multiple_condition_query" class="lr-query-wrap">
                                    <div class="lr-query-btn" id="spn_Search" style="font-size:10px;width:80px;">
                                        <i  class="fa fa-search"></i>&nbsp;查询</>  
                                    </div>
                                   
                                </div>
                                </div>
                                </div>
                             <div class=" lr-layout-tool-right">
                                 <div class="btn-group">
                                     <a id="lr-Add" class="btn btn-default" onclick="btn_Apply(event)"><i class="fa fa-plus"></i>&nbsp;反冲料申请</a>
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






