import 'package:flutter/material.dart';
import 'package:perwha/model/PermitDetails.dart';

class CustomSearchBar extends SearchDelegate {
  CustomSearchBar(this.permitResponse);
  List<PermitDetails> permitResponse;

  @override
  String get searchFieldLabel => "Enter location to search";

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    for (var permit in permitResponse) {
      if (permit.locality!.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(permit.locality!);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          onTap: (){
            print(result);
            close(context, result);
          },
          title: Text(result),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    for (var permit in permitResponse) {
      if (permit.locality!.contains(query.toLowerCase())) {
        matchQuery.add(permit.locality!);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          onTap: (){
            print(result);
            close(context, result);
          },
          title: Text(result),
        );
      },
    );
  }
  
}