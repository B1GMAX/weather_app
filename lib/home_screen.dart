import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/bloc.dart';
import 'package:weather_app/second_screen.dart';

import 'information.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<Bloc>(
      create: (BuildContext context) => Bloc()..getPosition(),
      dispose: (context, bloc) => bloc.dispose(),
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
              title: StreamBuilder<bool>(
                  stream: context.read<Bloc>().toggleStream,
                  initialData: true,
                  builder: (context, snapshot) {
                    final currentValue = snapshot.data!
                        ? AppLocalizations.of(context).hourly
                        : AppLocalizations.of(context).daily;
                    return DropdownButton<String>(
                      value: currentValue,
                      items: <String>[
                        AppLocalizations.of(context).hourly,
                        AppLocalizations.of(context).daily,
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (currentValue != value) {
                          context.read<Bloc>().changeData();
                        }
                      },
                    );
                  })),
          backgroundColor: Colors.indigo,
          body: StreamBuilder<String>(
            initialData: '',
            stream: context.read<Bloc>().streamString,
            builder: (context, snapshot) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      snapshot.data!,
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    const SizedBox(height: 40),
                    StreamBuilder<List<Information>>(
                      initialData: [],
                      stream: context.read<Bloc>().stream,
                      builder: (context, snapshot) {
                        return Container(
                          height: 90,
                          child: ListView.builder(
                            itemCount: snapshot.data!.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => SecondScreen(
                                                wind: snapshot
                                                    .data![index].speedOfWind,
                                                description: snapshot
                                                    .data![index].description,
                                                city:
                                                    snapshot.data![index].city,
                                              )));
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  width: 150,
                                  margin: EdgeInsets.only(left: 15, right: 15),
                                  color: Colors.white,
                                  child: ListTile(
                                    title:
                                        Text('${snapshot.data![index].dtTxt}'),
                                    subtitle: Text(
                                      '${snapshot.data![index].temp.toInt()} C',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
