import 'package:flutter/material.dart';

class SinglePOIView extends StatelessWidget {
  const SinglePOIView({super.key, required this.poiName, required this.poiURL});
  final String poiName, poiURL;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          title: Text(poiName),
          actions: [IconButton(onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }, icon: const Icon(Icons.home))],
        ),
        body: Column(
          children: [
            Container(
              height: 350.0,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Image.network(poiURL, fit: BoxFit.fitHeight),
            ),
            Expanded(
              child: Container(
                  padding: const EdgeInsets.all(20), child: const Steps()),
            ),
          ],
        ));
  }
}

class Step {
  Step(this.title, this.body, [this.isExpanded = false]);

  String title;
  String body;
  bool isExpanded;
}

List<Step> getSteps() {
  return [
    Step('Curiosità',
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla ut pharetra mi. Nam nec justo quis urna accumsan rhoncus eu eget nunc. Cras auctor lectus libero, cursus auctor nisi imperdiet tempus. Sed ultricies metus auctor nisi faucibus, eget malesuada enim scelerisque. Suspendisse efficitur, dolor id laoreet maximus, sem ex fermentum metus, vel viverra libero ligula sed quam. Ut dignissim nisl interdum fermentum pharetra. Duis eleifend, elit eget ornare sagittis, lacus diam congue ligula, gravida tristique velit urna a erat. Pellentesque blandit congue convallis. Ut cursus lectus id consectetur pellentesque. Suspendisse aliquet odio a neque imperdiet, quis pharetra nibh vestibulum. Sed ultricies mauris tortor, nec malesuada nisi ultricies in. Mauris semper ornare nisi, sit amet efficitur elit placerat in. Fusce ullamcorper ante arcu, ut malesuada risus porttitor sit amet. Aliquam semper ex eu magna vehicula maximus. Phasellus vitae malesuada lorem. Nunc magna libero, consequat sed aliquam at, fermentum ut dui.'),
    Step('Cenni storici',
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla ut pharetra mi. Nam nec justo quis urna accumsan rhoncus eu eget nunc. Cras auctor lectus libero, cursus auctor nisi imperdiet tempus. Sed ultricies metus auctor nisi faucibus, eget malesuada enim scelerisque. Suspendisse efficitur, dolor id laoreet maximus, sem ex fermentum metus, vel viverra libero ligula sed quam. Ut dignissim nisl interdum fermentum pharetra. Duis eleifend, elit eget ornare sagittis, lacus diam congue ligula, gravida tristique velit urna a erat. Pellentesque blandit congue convallis. Ut cursus lectus id consectetur pellentesque. Suspendisse aliquet odio a neque imperdiet, quis pharetra nibh vestibulum. Sed ultricies mauris tortor, nec malesuada nisi ultricies in. Mauris semper ornare nisi, sit amet efficitur elit placerat in. Fusce ullamcorper ante arcu, ut malesuada risus porttitor sit amet. Aliquam semper ex eu magna vehicula maximus. Phasellus vitae malesuada lorem. Nunc magna libero, consequat sed aliquam at, fermentum ut dui.'),
  ];
}

class Steps extends StatefulWidget {
  const Steps({Key? key}) : super(key: key);

  @override
  State<Steps> createState() => _StepsState();
}

class _StepsState extends State<Steps> {
  final List<Step> _steps = getSteps();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: _renderSteps(),
      ),
    );
  }

  Widget _renderSteps() {
    return ExpansionPanelList.radio(
      children: _steps.map<ExpansionPanelRadio>((Step step) {
        return ExpansionPanelRadio(
            canTapOnHeader: true,
            backgroundColor: Colors.grey.shade200,
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                title: Text(step.title),
              );
            },
            body: Container(
                height: 135,
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                child: SingleChildScrollView(child: Text(step.body))),
            value: step.title);
      }).toList(),
    );
  }
}
