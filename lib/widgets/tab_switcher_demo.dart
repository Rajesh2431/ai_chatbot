// import 'package:flutter/material.dart';
// import 'animated_tab_switcher.dart';

// /// Demo widget to showcase the animated tab switcher
// class TabSwitcherDemo extends StatelessWidget {
//   const TabSwitcherDemo({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Know-Grow Tab Switcher Demo'),
//         backgroundColor: const Color(0xFF3498DB),
//         foregroundColor: Colors.white,
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(
//                 Icons.swap_horiz,
//                 size: 80,
//                 color: Color(0xFF3498DB),
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 'Animated Tab Switcher',
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF2C3E50),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               const Text(
//                 'Seamlessly switch between Know and Grow screens with smooth animations.',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.grey,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 40),
              
//               // Features list
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[50],
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Features:',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF2C3E50),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     _buildFeatureItem('🎯', 'Smooth fade and slide animations'),
//                     _buildFeatureItem('🔄', 'Seamless tab transitions'),
//                     _buildFeatureItem('📱', 'Know screen with SOAR cards and goals'),
//                     _buildFeatureItem('🌱', 'Grow screen with games and wellness tips'),
//                     _buildFeatureItem('📊', 'Show tab for future analytics'),
//                     _buildFeatureItem('🎨', 'Beautiful button animations'),
//                   ],
//                 ),
//               ),
              
//               const SizedBox(height: 40),
              
//               // Launch buttons
//               Column(
//                 children: [
//                   SizedBox(
//                     width: double.infinity,
//                     height: 56,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const AnimatedTabSwitcher(initialTab: 0),
//                           ),
//                         );
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF3498DB),
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         elevation: 4,
//                       ),
//                       child: const Text(
//                         'Start with Know Tab',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   SizedBox(
//                     width: double.infinity,
//                     height: 56,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const AnimatedTabSwitcher(initialTab: 1),
//                           ),
//                         );
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF2ECC71),
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         elevation: 4,
//                       ),
//                       child: const Text(
//                         'Start with Grow Tab',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFeatureItem(String emoji, String text) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           Text(
//             emoji,
//             style: const TextStyle(fontSize: 16),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               text,
//               style: const TextStyle(
//                 fontSize: 14,
//                 color: Color(0xFF2C3E50),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }