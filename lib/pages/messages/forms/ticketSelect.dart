import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:mor_release/models/ticket.dart';
import 'package:mor_release/pages/messages/forms/ticketDoc.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../../models/area.dart';

class TicketSelect extends StatefulWidget {
  final List<TicketType> types;
  final List<Store> stores;
  final String distrId;
  TicketSelect(this.stores, this.types, this.distrId, {Key key})
      : super(key: key);

  _TicketSelectState createState() => _TicketSelectState();
}

class _TicketSelectState extends State<TicketSelect> {
  String type;
  String store = '';
  bool isSelected = false;
  void _valueChanged(bool v) {
    setState(() {
      isSelected = v;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      title: Directionality(
        child: Icon(
          Icons.support_agent_sharp,
          size: 40,
        ),
        textDirection: TextDirection.rtl,
      ),
      content: FormBuilder(
        //  autovalidate: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FormBuilderField(
                name: "store",
                validator: FormBuilderValidators.compose(
                    [FormBuilderValidators.required(context)]),
                // initialValue: '01',
                //key: _formKey,
                enabled: true,
                builder: (FormFieldState<dynamic> field) {
                  return ScopedModelDescendant<MainModel>(
                    builder:
                        (BuildContext context, Widget child, MainModel model) {
                      return Directionality(
                        textDirection: TextDirection.ltr,
                        child: DropdownButton(
                          hint: Text('فرع'),
                          isExpanded: true,
                          items: widget.stores.map((option) {
                            return DropdownMenuItem(
                                child: Text("${option.name}"),
                                value: option.storeId);
                          }).toList(),
                          value: field.value,
                          onChanged: (value) async {
                            field.didChange(value);
                            store = value;
                            _valueChanged(true);
                            print('dropDown value:$value');
                            // int x = types.indexOf(value);
                          },
                        ),
                      );
                    },
                  );
                }),
            store.isNotEmpty
                ? FormBuilderField(
                    name: "type",
                    validator: FormBuilderValidators.compose(
                        [FormBuilderValidators.required(context)]),
                    // initialValue: [],
                    //key: _formKey,
                    enabled: true,
                    builder: (FormFieldState<dynamic> field) {
                      return ScopedModelDescendant<MainModel>(
                        builder: (BuildContext context, Widget child,
                            MainModel model) {
                          return Directionality(
                            textDirection: TextDirection.ltr,
                            child: DropdownButton(
                              hint: Text('نوع الشكوى'),
                              isExpanded: true,
                              items: widget.types.map((option) {
                                return DropdownMenuItem(
                                    child: Text("${option.ticketType}"),
                                    value: option.ticketType);
                              }).toList(),
                              value: field.value,
                              onChanged: (value) async {
                                field.didChange(value);
                                type = value;
                                _valueChanged(true);
                                print('dropDown value:$value');
                                // int x = types.indexOf(value);
                              },
                            ),
                          );
                        },
                      );
                    })
                : Container(),
          ],
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.pink[900],
            size: 34,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        isSelected
            ? IconButton(
                icon: Icon(
                  Icons.done,
                  color: Colors.green,
                  size: 34,
                ),
                onPressed: () async {
                  // print(selectedValue);
                  Navigator.of(context).pop();

                  showDialog(
                      context: context,
                      builder: (_) => DocForm(store, type, widget.distrId,
                          getDocBase(type), getDocProblem(type)));
                },
              )
            : Container(),
      ],
    );
  }

  bool getDocBase(String value) {
    TicketType _types;
    _types = widget.types.firstWhere((v) => v.ticketType == value);
    int _typeIndex = widget.types.indexOf(_types);
    bool _docBase = widget.types.elementAt(_typeIndex).docBased;
    return _docBase;
  }

  String getDocProblem(String value) {
    print(value);
    TicketType _types;
    _types = widget.types.firstWhere((v) => v.ticketType == value);
    int _typeIndex = widget.types.indexOf(_types);
    String _docProblem = widget.types.elementAt(_typeIndex).docProblem;
    return _docProblem;
  }
}
