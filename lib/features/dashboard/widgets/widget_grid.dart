import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_widget_model.dart';
import '../controller/dashboard_controller.dart';
import 'widget_card.dart';

class WidgetGrid extends StatelessWidget {
  const WidgetGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<DashboardController>(context);
    final widgets = controller.activeWidgets;

    if (widgets.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 64.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('📭', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                'Workspace is empty',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter Edit Mode and add widgets to personalize your workspace.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                    ),
              ),
            ],
          ),
        ),
      );
    }

    // Assemble widgets into grid items natively using rows and columns
    final List<Widget> gridItems = [];
    int i = 0;
    
    while (i < widgets.length) {
      final current = widgets[i];
      if (current.size == 'small') {
        // If next widget exists and is also small, put them in a row together
        if (i + 1 < widgets.length && widgets[i + 1].size == 'small') {
          final next = widgets[i + 1];
          final currentIdx = i;
          final nextIdx = i + 1;
          
          gridItems.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildDragTarget(context, current, currentIdx),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDragTarget(context, next, nextIdx),
                  ),
                ],
              ),
            ),
          );
          i += 2;
        } else {
          // If small widget has no small companion, let it occupy half width, other half empty
          final currentIdx = i;
          gridItems.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildDragTarget(context, current, currentIdx),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: SizedBox(),
                  ),
                ],
              ),
            ),
          );
          i += 1;
        }
      } else {
        // Medium and Large widgets span the full width of their row
        final currentIdx = i;
        gridItems.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildDragTarget(context, current, currentIdx),
          ),
        );
        i += 1;
      }
    }

    return Column(
      children: gridItems,
    );
  }

  Widget _buildDragTarget(BuildContext context, DashboardWidgetModel model, int index) {
    final controller = Provider.of<DashboardController>(context, listen: false);
    
    return DragTarget<DashboardWidgetModel>(
      onWillAcceptWithDetails: (details) => details.data.id != model.id,
      onAcceptWithDetails: (details) {
        final dragged = details.data;
        final oldIndex = controller.activeWidgets.indexWhere((w) => w.id == dragged.id);
        controller.reorderWidgets(oldIndex, index);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;
        final theme = Theme.of(context);
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isHovered 
                  ? theme.colorScheme.primary 
                  : Colors.transparent,
              width: isHovered ? 2.0 : 0.0,
            ),
            boxShadow: isHovered 
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.25),
                      blurRadius: 16,
                    )
                  ] 
                : [],
          ),
          // Wrap with a margin shift when hovered to show premium visual sorting depth
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: isHovered ? 4.0 : 0.0,
              vertical: isHovered ? 4.0 : 0.0,
            ),
            child: WidgetCard(widgetModel: model),
          ),
        );
      },
    );
  }
}
