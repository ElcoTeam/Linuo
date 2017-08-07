<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ThresholdConfig.aspx.cs" Inherits="LiNuoMes.BaseConfig.ThresholdConfig" %>

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

         var lastSelected = "";

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
            $gridTable.jqGrid({
                url: "GetSetBaseConfig.ashx",
                postData: { Action: "MES_THRESHOLD_CONFIG_LIST" },
                datatype: "json",
                height: $('#areascontent').height() - 200,
                width: $('#areascontent').width,
                rowNum: -1,
                colModel: [
                    { label: 'THID',     name: 'THID', hidden: true },
                    { label: '序号', name: 'ID', index: 'ID', width: 50, align: 'center', sortable: false },
                    { label: '工序名称', name: 'ProcessName', index: 'ProcessName', width: 180, align: 'center', sortable: false },
                    { label: '物料编号', name: 'ItemNumber', index: 'ItemNumber', width: 200, align: 'center', sortable: false },
                    { label: '物料名称', name: 'ItemName', index: 'ItemName', width: 400, align: 'left', sortable: false },
                    {
                        label: '最大拉动数量', name: 'MaxPullQty', index: 'MaxPullQty', width: 100, align: 'center',
                        sortable: false,
                        editable: true,
                        editrules: {
                            number: true,
                            custom: false,
                            required: true,
                            minValue: 1,
                            maxValue: 50000
                        }
                    },
                    {
                        label: '到位时限', name: 'MinTrigQty', index: 'MinTrigQty', width: 100, align: 'center',
                        sortable: false,
                        editable: true,
                        editrules: {
                            number: true,
                            custom: false,
                            required: true,
                            minValue: 1,
                            maxValue: 50000
                        }
                    },
                    {
                        label: '单位', name: 'UOM', index: 'UOM', width: 100, align: 'center',
                        sortable: false,
                        editable: true,
                        editrules: {
                            custom_func: validateUom,
                            custom: true,
                            required: true
                        }
                    },
                    { label: '操 作',  name:'opcell', index:'opcell', width: 160, align: 'center', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            return '  <span id=\"btn_edit'+ rowObject.ID + '\" onclick=\"onBtnEdit(  \'' + rowObject.ID + '\')\" class=\"label label-success\" style=\"cursor: pointer;            \"                   ><i class="fa fa-edit" ></i>修改</span>'
                                   + '<span id=\"btn_yes' + rowObject.ID + '\" onclick=\"onBtnOk(    \'' + rowObject.ID + '\')\" class=\"label label-success\" style=\"cursor: pointer;display:none\"                   ><i class="fa fa-check"></i>确认</span>'
                                   + '<span id=\"btn_no'  + rowObject.ID + '\" onclick=\"onBtnCancel(\'' + rowObject.ID + '\')\" class=\"label label-warning\" style=\"cursor: pointer;display:none; margin-left:10px;\"><i class="fa fa-times"></i>取消</span>'
                            ;
                        }
                    },
                ],
                shrinkToFit: true,
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

            var strListOptions = "";
            $.ajax({
                url: "GetSetBaseConfig.ashx",
                data: { Action: "MES_PROC_CONFIG_LIST" },
                type: "post",
                datatype: "json",
                success: function (data) {
                    data = JSON.parse(data);
                    for (i in data) {
                        strListOptions += "<option value=\"" + data[i].ProcessCode + "\" >" + data[i].ProcessName + "</option>";
                    }
                    $("#ProcessCode").html("<option value=''>请选择...</option> " + strListOptions);
                },
                error: function (msg) {
                    alert(msg.responseText);
                }
            });

            function validateUom(value, column) {
                if (String(value).length > 4) {
                    return [false, "单位长度不要大于四个字符!"];
                }
                else {
                    return [true, ""];
                }
            };

            //查询事件
            $("#spn_Search").click(function () {
                var ProcessCode = $("#ProcessCode").val();
                var ItemNumber = $("#ItemNumber").val();
                $gridTable.jqGrid('setGridParam', {
                    postData: {
                        ProcessCode: ProcessCode,
                        ItemNumber : ItemNumber
                    }
                }).trigger('reloadGrid');
            });

            //查询回车

            $('#ItemName').bind('keypress', function (event) {
                if (event.keyCode == "13") {
                    $('#spn_Search').trigger("click");
                }
            });

            $('#ProcessCode').bind('change', function (event) {
                $('#spn_Search').trigger("click");
            });
        }

        function onBtnEdit(id) {
            //if (id && id !== lastSelected) 
            //{因为本文不存在同一行同时点击多次的edit命令情况, 因此, 此判断条件去除.
                $('#gridTable').jqGrid('restoreRow', lastSelected);
                onNormalfunc(lastSelected);
                $('#gridTable').jqGrid('editRow', id, {
                    keys: false,
                    restoreAfterError: true,
                    oneditfunc: onMyEditfunc
                });
                lastSelected = id;
            //}
        }

        function onBtnOk(id) {
            var rowData = $('#gridTable').jqGrid('getRowData', id);
            var saveparameters = {
                    url: "GetSetBaseConfig.ashx",
                    mtype: "POST",
                    restoreAfterError: true,
                    extraparam: {
                        "Action": "MES_THRESHOLD_CONFIG_EDIT",
                        "THID"  : rowData.THID
                },
                aftersavefunc: onNormalfunc,
                successfunc: onSuccessfun,
                errorfunc: onErrorfun
            }
            $('#gridTable').jqGrid('saveRow', id, saveparameters);
        }

        function onBtnCancel(id) {
            onNormalfunc(id);
            $('#gridTable').jqGrid('restoreRow', id);
        }

        function onMyEditfunc(rowid) {
            $("#btn_yes"  + rowid).show();
            $("#btn_no"   + rowid).show();
            $("#btn_edit" + rowid).hide();
        }

        function onNormalfunc(rowid) {
            $("#btn_yes"  + rowid).hide();
            $("#btn_no"   + rowid).hide();
            $("#btn_edit" + rowid).show();
        }

        function onSuccessfun(response) {
            var result = JSON.parse(response.responseText);
            dialogMsg(result.msg, 1);
            return true;
        }

        function onErrorfun(response) {
            var result = JSON.parse(response.responseText);
            dialogMsg(result.msg, -1);
            return false;
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
                                    <th><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px;">物料拉动阈值维护</strong></th>
                                    <td></td>
                                </tr>
                            </table>
                        </div>
                        <div class="panel-body" style="text-align:left">
                            <table id="form1" class="form" border="0" style="width:100%">
                                <tr>
                                    <th class="formTitle" style="text-align:right">工序名称：</th>
                                    <td class="formValue" >
                                        <select class="form-control" id="ProcessCode"></select>
                                    </td>                                
                                    <td class="formTitle" style="text-align:right">物料编号：</td>
                                    <td class="formValue" >
                                        <input type="text" class="form-control" id="ItemNumber" placeholder="物料编号">
                                    </td>
                                    <td class="formValue" style="text-align:right">                                           
                                        <a id="spn_Search" class="btn btn-primary"><i class="fa fa-search"></i>&nbsp;查询</a>  
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
               width:80px;
           } 
           .form-control {
               font-size:15px;
               width:150px;
               height:30px;
           }
           .aa{
               width:10px;
               height:30px;
           }
           #form1{
               margin-left:0px;
           }
       } 
       @media screen and (min-width: 1400px) { 
          .formTitle {
              font-size:30px;
              width:260px;
          } 
          .form-control {
               font-size:30px;
               width:300px;
               height:45px;
           }
           #form1{
               margin: 0px 0px 0px 0px;
           }
       } 
    </style>
    
</body>
</html>
