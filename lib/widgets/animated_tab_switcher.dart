// import 'package:flutter/material.dart';
// import '../screens/know_screen.dart';
// import '../screens/grow_screen.dart';

// class AnimatedTabSwitcher extends StatefulWidget {
//   final int initialTab; // 0 = Know, 1 = Grow, 2 = Show

//   const AnimatedTabSwitcher({super.key, this.initialTab = 0});

//   @override
//   State<AnimatedTabSwitcher> createState() => _AnimatedTabSwitcherState();
// }

// class _AnimatedTabSwitcherState extends State<AnimatedTabSwitcher>
//     with TickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;

//   int _currentTab = 0;

//   @override
//   void initState() {
//     super.initState();
//     _currentTab = widget.initialTab;

//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 400),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );

//     _slideAnimation =
//         Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(
//           CurvedAnimation(
//             parent: _animationController,
//             curve: Curves.easeOutCubic,
//           ),
//         );

//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   void _switchTab(int newTab) {
//     if (newTab == _currentTab) return;

//     _animationController.reverse().then((_) {
//       setState(() {
//         _currentTab = newTab;
//       });
//       _animationController.forward();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       body: SafeArea(
//         child: Column(
//           children: [
//             _buildHeader(),
//             _buildTabButtons(),
//             Expanded(
//               child: AnimatedBuilder(
//                 animation: _animationController,
//                 builder: (context, child) {
//                   return FadeTransition(
//                     opacity: _fadeAnimation,
//                     child: SlideTransition(
//                       position: _slideAnimation,
//                       child: _buildTabContent(),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.grey[300],
//             ),
//           ),
//           const Text(
//             'Strive High',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: Color(0xFF2C3E50),
//             ),
//           ),
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: Colors.grey[300],
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: const Icon(Icons.menu, color: Colors.grey, size: 20),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTabButtons() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           _buildTabButton('Know', 0),
//           const SizedBox(width: 8),
//           _buildTabButton('Grow', 1),
//           const SizedBox(width: 8),
//           _buildTabButton('Show', 2),
//         ],
//       ),
//     );
//   }

//   Widget _buildTabButton(String label, int index) {
//     final isSelected = _currentTab == index;

//     return GestureDetector(
//       onTap: () => _switchTab(index),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//         decoration: BoxDecoration(
//           color: isSelected ? const Color(0xFF3498DB) : Colors.white,
//           borderRadius: BorderRadius.circular(50),
//           boxShadow: [
//             BoxShadow(
//               color: isSelected
//                   ? const Color(0xFF3498DB).withValues(alpha: 0.3)
//                   : Colors.black.withValues(alpha: 0.05),
//               blurRadius: isSelected ? 8 : 4,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
//         child: Text(
//           label,
//           style: TextStyle(
//             color: isSelected ? Colors.white : const Color(0xFF3498DB),
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTabContent() {
//     switch (_currentTab) {
//       case 0:
//         return const KnowScreen();
//       case 1:
//         return const GrowScreen();
//       case 2:
//         return _buildShowContent();
//       default:
//         return const KnowScreen();
//     }
//   }

//   Widget _buildShowContent() {
//     return const Center(
//       child: Padding(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.analytics, size: 80, color: Color(0xFF3498DB)),
//             SizedBox(height: 20),
//             Text(
//               'Show Tab',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF2C3E50),
//               ),
//             ),
//             SizedBox(height: 12),
//             Text(
//               'Progress tracking and analytics coming soon!',
//               style: TextStyle(fontSize: 16, color: Colors.grey),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
