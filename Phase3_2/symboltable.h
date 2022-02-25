#ifndef SYMBOLTABLE_H
#define SYMBOLTABLE_H

#include <unordered_map>
#include <vector>
#include <iostream>

using namespace std;

class SymbolTable {
  public:
    enum Type { INT, ARR, FUNC, ERR };

  private:
    vector<unordered_map<string, Type> > _table;

    bool inScope(string id) {
      for(int i = _table.size() - 1; i >= 0; i--)
        if(_table[i].count(id))
          return true;
      return false;
    }
  
  public:
    SymbolTable() {
      _table.push_back(unordered_map<string, Type>());
    }

    bool addSymbol(string id, Type type, int l) {
      if(inScope(id)) {
        cout << "Error line " << l << ": symbol \"" << id << "\" is multiply-defined.\n";
        return false;
      }
      _table.back()[id] = type;
      return true;
    }

    void EnterNewScope() {
      _table.push_back(unordered_map<string, Type>());
    }

    void LeaveCurrentScope() {
      _table.pop_back();
    }

    bool checkUsage(string id, Type context, int l) {
      for(int i = _table.size() - 1; i >= 0; i--)
        if(_table[i].count(id)) {
          if(context != _table[i][id]) {
            if(_table[i][id] == INT)
              cout << "Error line " << l << ": variable \"" << id << "\" was declared an integer.\n";
            else if(_table[i][id] == ARR) {
              if(context == INT)
                cout << "Error line " << l << ": used array variable \"" << id << "\" is missing a specified index.\n";
              else if(context == FUNC)
                cout << "Error line " << l << ": variable \"" << id << "\" was declared an array.\n";
            }
            else if(_table[i][id] == FUNC) {
              cout << "Error line " << l << ": symbol \"" << id << "\" was declared a function.\n";
            }
            return false;
          }
          else
            return true;
        }
      if(context == FUNC)
        cout << "Error line " << l << ": function \"" << id << "\" was not previously declared.\n";
      else
        cout << "Error line " << l << ": used variable \"" << id << "\" was not previously declared.\n";
      return false;
    }

    bool checkForMain() {
      if(!inScope("main")) {
        cout << "Error: main function was not defined.\n";
        return false;
      }
      return true;
    }
};

#endif //SYMBOLTABLE_H
