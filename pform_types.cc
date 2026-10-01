/*
 * Copyright (c) 2007-2026 Stephen Williams (steve@icarus.com)
 *
 *    This source code is free software; you can redistribute it
 *    and/or modify it in source code form under the terms of the GNU
 *    General Public License as published by the Free Software
 *    Foundation; either version 2 of the License, or (at your option)
 *    any later version.
 *
 *    This program is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with this program; if not, write to the Free Software
 *    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 */


# include  "pform_types.h"
# include  "PExpr.h"
# include  "netclass.h"
# include  "netenum.h"

data_type_t::~data_type_t()
{
}

void data_type_t::relocate_for_bind(LexicalScope*)
{
      lexical_pos(UINT_MAX);
}

static void relocate_bind_dimensions(std::list<pform_range_t>&dims,
                                     LexicalScope*scope)
{
      for (auto&range : dims) {
            if (range.first) range.first->relocate_for_bind(scope);
            if (range.second) range.second->relocate_for_bind(scope);
      }
}

void type_identifier_t::relocate_for_bind(LexicalScope*scope)
{
      data_type_t::relocate_for_bind(scope);
      if (identifier_) identifier_->relocate_for_bind(scope);
}

void vector_type_t::relocate_for_bind(LexicalScope*scope)
{
      data_type_t::relocate_for_bind(scope);
      if (pdims) relocate_bind_dimensions(*pdims, scope);
}

void array_base_t::relocate_for_bind(LexicalScope*scope)
{
      data_type_t::relocate_for_bind(scope);
      if (base_type) base_type->relocate_for_bind(scope);
      if (dims) relocate_bind_dimensions(*dims, scope);
}

void enum_type_t::relocate_for_bind(LexicalScope*scope)
{
      data_type_t::relocate_for_bind(scope);
      if (base_type) base_type->relocate_for_bind(scope);
      if (names) {
            for (auto&name : *names)
                  if (name.parm) name.parm->relocate_for_bind(scope);
      }
}

void struct_type_t::relocate_for_bind(LexicalScope*scope)
{
      data_type_t::relocate_for_bind(scope);
      if (!members) return;

      for (auto*member : *members) {
            if (!member) continue;
            if (member->type) member->type->relocate_for_bind(scope);
            if (!member->names) continue;
            for (auto*name : *member->names) {
                  if (!name) continue;
                  relocate_bind_dimensions(name->index, scope);
                  if (name->expr) name->expr->relocate_for_bind(scope);
            }
      }
}

type_identifier_t::type_identifier_t(PEIdent *identifier)
: identifier_(identifier)
{
}

type_identifier_t::~type_identifier_t() = default;

PNamedItem::SymbolType data_type_t::symbol_type() const
{
      return TYPE;
}

string_type_t::~string_type_t()
{
}

atom_type_t size_type (atom_type_t::INT, true);

PNamedItem::SymbolType enum_name_t::symbol_type() const
{
      return ENUM;
}

PNamedItem::SymbolType enum_type_t::symbol_type() const
{
      return ENUM;
}

PNamedItem::SymbolType class_type_t::symbol_type() const
{
      return CLASS;
}

bool typedef_t::set_data_type(data_type_t *t)
{
      if (data_type.get())
	    return false;

      data_type.reset(t);

      return true;
}

bool typedef_t::set_basic_type(type_restrict_t type)
{
      return basic_type.merge(type);
}

bool type_restrict_t::merge(type_restrict_t other)
{
      if (other.type == ANY)
	    return true;
      if (this->type != ANY && other.type != this->type)
	    return false;

      this->type = other.type;

      return true;
}

bool type_restrict_t::matches(ivl_type_t ivl_type) const
{
      switch (this->type) {
      case ENUM:
	    return dynamic_cast<const netenum_t *>(ivl_type);
      case STRUCT: {
	    const netstruct_t *struct_type = dynamic_cast<const netstruct_t *>(ivl_type);
	    return struct_type && !struct_type->union_flag();
      }
      case UNION: {
	    const netstruct_t *struct_type = dynamic_cast<const netstruct_t *>(ivl_type);
	    return struct_type && struct_type->union_flag();
      }
      case CLASS:
	    return dynamic_cast<const netclass_t *>(ivl_type);
      default:
	    return true;
      }
}

std::ostream& operator<< (std::ostream&out, const type_restrict_t& type)
{
	switch (type.type) {
	case type_restrict_t::ANY:
		out << "any";
		break;
	case type_restrict_t::ENUM:
		out << "enum";
		break;
	case type_restrict_t::STRUCT:
		out << "struct";
		break;
	case type_restrict_t::UNION:
		out << "union";
		break;
	case type_restrict_t::CLASS:
		out << "class";
		break;
	}

	return out;
}
