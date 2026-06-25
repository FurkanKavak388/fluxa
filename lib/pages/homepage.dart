import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluxa/widgets/avaliablediscount.dart';
import 'package:fluxa/widgets/campaignlist.dart';
import 'package:fluxa/widgets/expenselist.dart';
import 'package:fluxa/widgets/gamewidget.dart';
import 'package:fluxa/widgets/mapcard.dart';
import 'package:fluxa/widgets/subsminimal.dart';
import 'package:fluxa/widgets/usechance.dart';
import '/models/story.dart';
import '/widgets/storylist.dart';
import '/widgets/invoicebuttonwithbadge.dart';

class HomePage extends StatelessWidget {
  final User? user;
  final List<Story> stories;

  const HomePage({Key? key, this.user, this.stories = const []}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalPadding = screenWidth * 0.04;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
          child: Column(
            children: [
              const StoryList(),
              const CampaignList(),
              UnpaidInvoiceCountWidget(),
              const MonthlyExpenseWidget(),
              UnusedDiscountsWidget(),

              
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: screenHeight * 0.15,
                      child: ChanceWidget(),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: screenHeight * 0.15,
                      child: MatchGameWidget(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              const GoToMapCard(),

              SizedBox(height: screenHeight * 0.02),

              SubscriptionPlansWidget(),

              SizedBox(height: screenHeight * 0.15),
            ],
          ),
        ),
      ),
    );
  }
}
